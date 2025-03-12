import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Userpage/PracticeuserDetailPage.dart';
import 'package:myproject/Userpage/eventuserdetail.dart';
import 'package:myproject/constant.dart';

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
      .collection('pratice')
      .orderBy('prt_date', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .where((doc) => doc.data().containsKey('checked') ? doc['checked'] == false : false) // ✅ กรองด้วย Dart
        .map((doc) {
      DateTime practiceDate;
      if (doc['prt_date'] is Timestamp) {
        practiceDate = (doc['prt_date'] as Timestamp).toDate();
      } else if (doc['prt_date'] is String) {
        practiceDate = DateTime.parse(doc['prt_date']);
      } else {
        practiceDate = DateTime.now(); // สำรองถ้า format ไม่ตรง
      }

      return {
        'id': doc.id,
        'title': doc['prt_title'] ?? "No Title",
        'date': practiceDate,
        'start_time': doc['prt_start_time'] ?? "No Time",
        'detail': doc['prt_detail'] ?? "No Details",
      };
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
  DateTime practiceDate;
  if (practice['date'] is String) {
    practiceDate = DateTime.parse(practice['date']);
  } else if (practice['date'] is Timestamp) {
    practiceDate = (practice['date'] as Timestamp).toDate();
  } else if (practice['date'] is DateTime) {
    practiceDate = practice['date'];
  } else {
    throw Exception("Invalid prt_date format: ${practice['date']}");
  }

  return FutureBuilder<bool>(
    future: _isUserJoined(Timestamp.fromDate(practiceDate)), // ✅ ใช้ `Timestamp`
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }
      bool isJoined = snapshot.data!;

      return ElevatedButton(
        onPressed: () async {
          if (isJoined) {
            await _cancelPractice(practiceDate); // ✅ อัปเดต `status` เป็น `"absent"`
          } else {
            await _joinPractice(practice['id']); // ✅ อัปเดต `status` เป็น `"on_time"`
          }

          // ✅ รีโหลดข้อมูลใหม่ให้ FutureBuilder
          setState(() {}); // 🔄 บังคับให้ UI อัปเดต
        },
        child: Text(isJoined ? "Cancel" : "Join",style: TextStyle(color: Colors.white),),
        style: ElevatedButton.styleFrom(
          backgroundColor: isJoined ? Colors.grey : red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    },
  );
}



/// 📌 ฟังก์ชันเช็คว่าผู้ใช้เข้าร่วมแล้วหรือยัง
Future<bool> _isUserJoined(Timestamp practiceDate) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!userDoc.exists) return false;
  String stuFirstName = userDoc['stu_firstname'];
  String stuLastName = userDoc['stu_lastname'];

  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('practice_users')
      .where('stu_firstname', isEqualTo: stuFirstName)
      .where('stu_lastname', isEqualTo: stuLastName)
      .where('prt_date', isEqualTo: practiceDate)
      .where('status', isEqualTo: 'on_time') // ✅ เช็คเฉพาะคนที่มากิจกรรม
      .get();

  return query.docs.isNotEmpty; // ✅ ถ้าเจอเอกสาร แสดงว่ามาแล้ว
}

/// 📌 ฟังก์ชันสำหรับเข้าร่วมการฝึกซ้อม
Future<void> _joinPractice(String practiceId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) throw Exception("User document not found");
    String stuFirstName = userDoc['stu_firstname'];
    String stuLastName = userDoc['stu_lastname'];

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('practice_users')
        .where('practice_id', isEqualTo: practiceId)
        .where('stu_firstname', isEqualTo: stuFirstName)
        .where('stu_lastname', isEqualTo: stuLastName)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'status': 'on_time'});
    }

    if (mounted) {
      setState(() {}); // ✅ รีโหลด UI
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("✅ เข้าร่วมกิจกรรมสำเร็จ!")));

  } catch (e) {
    print("❌ Error joining practice: $e");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("❌ ไม่สามารถเข้าร่วมกิจกรรมได้!")));
  }
}

/// 📌 ฟังก์ชันสำหรับยกเลิกการฝึกซ้อม
Future<void> _cancelPractice(DateTime practiceDate) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) throw Exception("User document not found");
    String stuFirstName = userDoc['stu_firstname'];
    String stuLastName = userDoc['stu_lastname'];

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('practice_users')
        .where('prt_date', isEqualTo: Timestamp.fromDate(practiceDate))
        .where('stu_firstname', isEqualTo: stuFirstName)
        .where('stu_lastname', isEqualTo: stuLastName)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("No matching document found to update.");
    }

    await query.docs.first.reference.update({'status': 'absent'});

    if (mounted) {
      setState(() {}); // ✅ รีโหลด UI
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ ยกเลิกกิจกรรมสำเร็จ! สถานะถูกเปลี่ยนเป็น absent."))
    );

  } catch (e) {
    print("❌ Error cancelling practice: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ ไม่สามารถยกเลิกกิจกรรมได้!")),
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
        title: Text('Schedule',style: TextStyle(color: Colors.white),),
        backgroundColor: red,
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
            fontSize: 18, fontWeight: FontWeight.bold, color: red),
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
      leading: Icon(Icons.access_time, color: red),
      title: Text(practice['title']),
      subtitle: Text(
          '${_formatDate(practice['date'])} - ${practice['start_time']}\n${practice['detail']}'),
      trailing: buildJoinCancelButton(practice), // ✅ ใช้ปุ่ม Join/Cancel
    ),
  );
}


  /// 📌 Card สำหรับ Announcement
  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.announcement, color: red),
        title: Text(announcement['title']),
        subtitle: Text(
            '${_formatDate(announcement['date'])}\n${announcement['detail']}'),
      ),
    );
  }
}
