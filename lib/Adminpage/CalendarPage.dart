import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Adminpage/CalendarPage/MakeAnnouncementPage.dart';
import 'package:myproject/Adminpage/CalendarPage/PracticeDetailPage.dart';
import 'package:myproject/Adminpage/CalendarPage/SetPracticeDatePage.dart';
import 'package:myproject/constant.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'SetPracticeDatePage.dart'; // หน้าเพิ่ม Practice
// import 'MakeAnnouncementPage.dart'; // หน้าเพิ่ม Announcement

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  /// 📌 ดึง `announcement` ตามวันที่เลือก
  Stream<List<Map<String, dynamic>>> _getAnnouncements() {
    return _firestore
        .collection('Announcement')
        .orderBy('ann_date',
            descending: false) // ✅ แสดงข้อมูลทั้งหมดเรียงตามวันที่
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['ann_title'],
          'date': (doc['ann_date'] as Timestamp)
              .toDate(), // ✅ แปลง Timestamp เป็น DateTime
          'start_time': doc['ann_start_time'],
          'detail': doc['ann_detail'],
        };
      }).toList();
    });
  }

  /// 📌 ดึง `practice` ตามวันที่เลือก
  Stream<List<Map<String, dynamic>>> _getPractices() {
    return _firestore
        .collection('pratice') // ✅ ตรวจสอบให้แน่ใจว่าสะกดตรงกับ Firestore
        .orderBy('prt_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          // ✅ ตรวจสอบและแปลง `prt_date` ให้เป็น `DateTime`
          DateTime practiceDate;
          if (doc['prt_date'] is Timestamp) {
            practiceDate = (doc['prt_date'] as Timestamp).toDate();
          } else if (doc['prt_date'] is String) {
            practiceDate = DateTime.parse(doc['prt_date']);
          } else {
            throw Exception("Invalid prt_date format: ${doc['prt_date']}");
          }

          // ✅ ใช้ `??` เพื่อป้องกัน `null`
          return {
            'id': doc.id,
            'title': doc.data().containsKey('prt_title')
                ? doc['prt_title'] ?? "No Title"
                : "No Title",
            'date': practiceDate,
            'start_time': doc.data().containsKey('prt_start_time')
                ? doc['prt_start_time'] ?? "No Time"
                : "No Time",
            'detail': doc.data().containsKey('prt_detail')
                ? doc['prt_detail'] ?? "No Details"
                : "No Details",
          };
        } catch (e) {
          print("❌ Error parsing practice: ${doc.id} - $e");
          return <String, dynamic>{}; // ✅ คืนค่า Map ว่างในกรณีที่มีข้อผิดพลาด
        }
      }).toList();
    });
  }

  /// 📌 ลบ `announcement` และอัปเดต UI
  void _deleteAnnouncement(String id) async {
    try {
      await _firestore
          .collection('Announcement')
          .doc(id)
          .delete(); // ✅ แก้ชื่อ Collection
      setState(() {}); // ✅ อัปเดต UI
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("✅ Announcement deleted")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Failed to delete: $e")));
    }
  }

  /// 📌 ลบ `practice` และอัปเดต UI
  void _deletePractice(String id, DateTime practiceDate) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // ✅ ลบเอกสาร `practice` ที่มี ID ตรงกับที่เลือก
      await firestore
          .collection('pratice')
          .doc(id)
          .delete(); // 🔥 ลบเฉพาะเอกสารนี้

      // ✅ ค้นหาและลบข้อมูลใน `practice_users` ที่เกี่ยวข้องกับ `practiceDate`
      QuerySnapshot query = await firestore
          .collection('practice_users')
          .where('prt_date', isEqualTo: practiceDate)
          .get();

      // ✅ ใช้ Batch เพื่อลบข้อมูลทั้งหมดใน `practice_users`
      WriteBatch batch = firestore.batch();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit(); // ✅ ลบทั้งหมดในครั้งเดียว

      // ✅ อัปเดต UI
      setState(() {});

      // ✅ แจ้งเตือนว่าลบสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Practice deleted successfully!")));
    } catch (e) {
      print("❌ Error deleting practice: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete practice.")));
    }
  }

  // /// 📌 ฟังก์ชันแปลง `Timestamp` เป็น `String`
  // String _formatDate(Timestamp timestamp) {
  //   DateTime dateTime = timestamp.toDate();
  //   return DateFormat('dd MMM yy HH:mm').format(dateTime);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            'Schedule',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: red),
      body: Column(
        children: [
          /// 🔹 **ปฏิทินเลือกวัน**
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),

          /// 🔹 **ขยายพื้นที่ให้ `ListView` เพื่อไม่ให้เกิด Error**
          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle(
                  'Events/Announcement',
                ),
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
                _buildSectionTitle('Practice'),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getPractices(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildNoDataMessage("No practices.");
                    }
                    return Column(
                      children: snapshot.data!.map((practice) {
                        return _buildPracticeCard(practice);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(title,
          style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: red)),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(message, style: TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    // ✅ ตรวจสอบและแปลง `announcement['date']` เป็น `DateTime`
    DateTime date;
    if (announcement['date'] is Timestamp) {
      date = (announcement['date'] as Timestamp).toDate();
    } else if (announcement['date'] is DateTime) {
      date = announcement['date'];
    } else {
      date = DateTime.now(); // เผื่อเกิดข้อผิดพลาด ใช้วันที่ปัจจุบันแทน
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.textsms, color: red),
        title: Text(announcement['title']),
        subtitle: Text(
          '${_formatDate(date)} - ${announcement['start_time']}\n${announcement['detail']}',
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => _deleteAnnouncement(announcement['id']),
        ),
      ),
    );
  }

  /// 📌 ปรับให้ `_formatDate()` รองรับ `DateTime`
  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yy HH:mm').format(dateTime);
  }

  Widget _buildPracticeCard(Map<String, dynamic> practice) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PracticeDetailPage(
                practiceId: practice['id']), // ✅ ใช้ doc.id เป็น practiceId
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(Icons.access_time, color: Colors.deepOrangeAccent),
          title: Text(practice['title']),
          subtitle: Text(
              '${_formatDate(practice['date'])} - ${practice['start_time']}\n${practice['detail']}'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      label: Text("Create",style: TextStyle(color: Colors.white),),
      icon: Icon(Icons.add,color: Colors.white,),
      backgroundColor: red,
      onPressed: () => _showCreateOptions(),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Announcement"),
            leading: Icon(Icons.textsms),
            onTap: () {
              Navigator.pop(context); // ปิด Bottom Sheet ก่อน
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MakeAnnouncementPage(
                      selectedDate: _selectedDate), // ✅ ส่ง selectedDate ไปด้วย
                ),
              );
            },
          ),
          ListTile(
            title: Text("Practice"),
            leading: Icon(Icons.access_time),
            onTap: () {
              Navigator.pop(context); // ปิด Bottom Sheet ก่อน
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SetPracticeDatePage(
                      selectedDate: _selectedDate), // ✅ ส่ง selectedDate ไปด้วย
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
