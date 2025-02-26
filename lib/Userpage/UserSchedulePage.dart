import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Userpage/PracticeuserDetailPage.dart';
import 'package:myproject/Userpage/eventuserdetail.dart';

class UserSchedulePage extends StatefulWidget {
  @override
  _UserSchedulePageState createState() => _UserSchedulePageState();
}

class _UserSchedulePageState extends State<UserSchedulePage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String studentId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// 📌 โหลดข้อมูล `stu_id` ของ User
  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          studentId = userDoc['user_id'];
        });
      }
    }
  }

  /// 📌 ดึงรายการฝึกซ้อม (`Practice`) และเรียงลำดับตามวันที่
Stream<List<Map<String, dynamic>>> _getPractices() {
  return _firestore
      .collection('pratice') // ✅ ตรวจสอบให้แน่ใจว่าสะกดตรงกับ Firestore
      .orderBy('prt_date', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      try {
        DateTime practiceDate;
        if (doc['prt_date'] is Timestamp) {
          practiceDate = (doc['prt_date'] as Timestamp).toDate();
        } else if (doc['prt_date'] is String) {
          practiceDate = DateTime.parse(doc['prt_date']);
        } else {
          throw Exception("Invalid prt_date format: ${doc['prt_date']}");
        }

        return {
          'id': doc.id,
          'title': doc['prt_title']?.toString() ?? "No Title",
          'date': practiceDate,
          'start_time': doc['prt_start_time']?.toString() ?? "No Time",
          'detail': doc['prt_detail']?.toString() ?? "No Details",
        }.cast<String, dynamic>(); // ✅ บังคับให้เป็น Map<String, dynamic>
      } catch (e) {
        print("❌ Error parsing practice: ${doc.id} - $e");
        return <String, dynamic>{}; // ✅ คืนค่า Map ว่างในกรณีที่มีข้อผิดพลาด
      }
    }).toList();
  });
}


  /// 📌 ดึงรายการประกาศ (`announcement`)
Stream<List<Map<String, dynamic>>> _getAnnouncements() {
  return _firestore
      .collection('Announcement') // ✅ ตรวจสอบให้แน่ใจว่าสะกดตรงกับ Firestore
      .orderBy('ann_date', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      try {
        DateTime announcementDate;
        if (doc['ann_date'] is Timestamp) {
          announcementDate = (doc['ann_date'] as Timestamp).toDate();
        } else if (doc['ann_date'] is String) {
          announcementDate = DateTime.parse(doc['ann_date']);
        } else {
          throw Exception("Invalid ann_date format: ${doc['ann_date']}");
        }

        return {
          'id': doc.id,
          'title': doc['ann_title']?.toString() ?? "No Title",
          'date': announcementDate,
          'start_time': doc['ann_start_time']?.toString() ?? "No Time",
          'detail': doc['ann_detail']?.toString() ?? "No Details",
        }.cast<String, dynamic>(); // ✅ บังคับให้เป็น Map<String, dynamic>
      } catch (e) {
        print("❌ Error parsing announcement: ${doc.id} - $e");
        return <String, dynamic>{}; // ✅ คืนค่า Map ว่างในกรณีที่มีข้อผิดพลาด
      }
    }).toList();
  });
}



Widget buildJoinCancelButton(Map<String, dynamic> practice) {
  return FutureBuilder<bool>(
    future: _isUserJoined(practice['date']), // ✅ เช็คว่าลงทะเบียนไว้หรือไม่
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator(); // กำลังโหลดข้อมูล
      }
      bool isJoined = snapshot.data!;

      return ElevatedButton(
        onPressed: () {
          if (isJoined) {
            _cancelPractice(practice['date']); // ✅ ยกเลิกการเข้าร่วม
          } else {
            _joinPractice(practice['date']); // ✅ ลงทะเบียน
          }
        },
        child: Text(isJoined ? "Cancel" : "Join"), // 🔄 สลับข้อความปุ่ม
        style: ElevatedButton.styleFrom(
          backgroundColor: isJoined ? Colors.grey : Colors.redAccent, // 🔄 สลับสีปุ่ม
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    },
  );
}

/// 📌 ฟังก์ชันเช็คว่าผู้ใช้เข้าร่วมแล้วหรือยัง
Future<bool> _isUserJoined(DateTime practiceDate) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  // ✅ ดึง `stu_id` จาก Firestore
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!userDoc.exists) return false;
  String stuId = userDoc['stu_id'];

  // ✅ เช็คว่ามี `stu_id` ใน `practice_users` หรือไม่
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('practice_users')
      .where('user_id', isEqualTo: stuId)
      .where('prt_date', isEqualTo: practiceDate)
      .get();

  return query.docs.isNotEmpty; // ถ้ามีเอกสาร → แสดงว่าเข้าร่วมแล้ว
}

/// 📌 ฟังก์ชันสำหรับเข้าร่วมการฝึกซ้อม
void _joinPractice(DateTime practiceDate) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) throw Exception("User document not found");
    String stuId = userDoc['stu_id'];

    await FirebaseFirestore.instance.collection('practice_users').add({
      'user_id': stuId,
      'prt_date': practiceDate,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Joined practice successfully!"))
    );

  } catch (e) {
    print("❌ Error joining practice: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to join practice."))
    );
  }
}

/// 📌 ฟังก์ชันสำหรับยกเลิกการฝึกซ้อม
void _cancelPractice(DateTime practiceDate) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) throw Exception("User document not found");
    String stuId = userDoc['stu_id'];

    // ✅ ค้นหาและลบข้อมูลใน `practice_users`
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('practice_users')
        .where('user_id', isEqualTo: stuId)
        .where('prt_date', isEqualTo: practiceDate)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Cancelled practice successfully!"))
    );

  } catch (e) {
    print("❌ Error cancelling practice: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to cancel practice."))
    );
  }
}


  /// 📌 ฟังก์ชันแปลง `DateTime` เป็น String
  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔹 **Today’s Practice**
            _buildSectionTitle('Today’s Practice'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getPractices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoDataMessage("No practice available.");
                }
                return _buildPracticeCard(snapshot.data!.first, true);
              },
            ),

            /// 🔹 **Announcement**
            _buildSectionTitle('Announcement'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getAnnouncements(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoDataMessage("No announcements.");
                }
                return Column(
                  children: snapshot.data!.map((announcement) {
                    return _buildAnnouncementCard(announcement);
                  }).toList(),
                );
              },
            ),

            /// 🔹 **Next Practice (Upcoming)**
            _buildSectionTitle('Next Practice'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getPractices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoDataMessage("No upcoming practice.");
                }
                return Column(
                  children: snapshot.data!.map((practice) {
                    return _buildPracticeCard(practice, false);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 Header ของแต่ละ Section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
      ),
    );
  }

  /// 📌 กรณีไม่มีข้อมูล
  Widget _buildNoDataMessage(String message) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(message, style: TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  /// 📌 Card สำหรับ Practice
  Widget _buildPracticeCard(Map<String, dynamic> practice, bool isToday) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.access_time, color: Colors.deepOrangeAccent),
        title: Text(practice['title']),
        subtitle: Text(
            '${_formatDate(practice['date'])} - ${practice['start_time']}\n${practice['detail']}'),
        trailing: ElevatedButton(
          onPressed: () =>
              _joinPractice(practice['date']), // ✅ ส่ง practice['date'] ไป
          child: Text("Join"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  /// 📌 Card สำหรับ Announcement
  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.announcement, color: Colors.redAccent),
        title: Text(announcement['title']),
        subtitle: Text(
            '${_formatDate(announcement['date'])}\n${announcement['detail']}'),
      ),
    );
  }
}
