import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Summarypracpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice History'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            /// 🔹 **History Section**
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildHistoryList(), // ✅ แสดงประวัติการฝึกซ้อม
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **ดึงข้อมูลประวัติ `practice` จาก Firestore**
  Widget _buildHistoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pratice') // ✅ เชื่อมต่อไปยัง `pratice`
          .orderBy('prt_date', descending: true) // ✅ เรียงจากล่าสุดไปเก่าสุด
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator()); // ⏳ แสดงโหลดข้อมูล
        }

        var practices = snapshot.data!.docs;

        if (practices.isEmpty) {
          return Center(child: Text("No practice history available.")); // ไม่มีข้อมูล
        }

        return Column(
          children: practices.map((doc) {
            var practice = doc.data() as Map<String, dynamic>;

            DateTime practiceDate =
                (practice['prt_date'] as Timestamp).toDate(); // ✅ แปลงเป็น DateTime

            return FutureBuilder<int>(
              future: _getAttendeeCount(doc.id), // ✅ ดึงจำนวนคนเข้าร่วม
              builder: (context, attendeeSnapshot) {
                int attendeeCount = attendeeSnapshot.data ?? 0;

                return Card(
                  elevation: 1,
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text(practice['prt_title'] ?? 'No Title'),
                    subtitle: Text(
                        '${_formatDate(practiceDate)} ${practice['prt_start_time']} - ${practice['prt_end_time']}'),
                    trailing: Text(
                      '$attendeeCount Attendee',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// 📌 **ดึงจำนวนผู้เข้าร่วมฝึกซ้อมจาก `practice_users`**
  Future<int> _getAttendeeCount(String practiceId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('practice_users')
        .where('practice_id', isEqualTo: practiceId)
        .get();
    return query.docs.length;
  }

  /// 📌 **ฟังก์ชันแปลง `DateTime` เป็น String**
  String _formatDate(DateTime dateTime) {
    return "${dateTime.day} ${_monthAbbreviation(dateTime.month)} ${dateTime.year}";
  }

  /// 📌 **แปลงเลขเดือนเป็นตัวย่อ เช่น `Dec`**
  String _monthAbbreviation(int month) {
    List<String> months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month];
  }
}
