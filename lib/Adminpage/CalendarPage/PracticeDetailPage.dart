import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PracticeDetailPage extends StatelessWidget {
  final String practiceId; // ✅ ใช้ doc.id เป็นตัวระบุ Practice

  PracticeDetailPage({required this.practiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Detail'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pratice') // ✅ ตรวจสอบให้ชื่อ Collection ตรงกัน
            .doc(practiceId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No Practice Found"));
          }

          var practiceData = snapshot.data!;
          DateTime practiceDate =
              (practiceData['prt_date'] as Timestamp).toDate();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 **Practice Title & Date**
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        practiceData['prt_title'] ?? 'No Title',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.brown),
                        onPressed: () {
                          // TODO: Implement Edit Function
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(practiceDate)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${practiceData['prt_start_time']} - ${practiceData['prt_end_time']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),

                  /// 🔹 **Practice Detail**
                  SizedBox(height: 16),
                  Text(
                    practiceData['prt_detail'] ?? 'No Description',
                    style: TextStyle(fontSize: 16),
                  ),

                  /// 🔹 **Budget Info**
                  SizedBox(height: 16),
                  Text(
                    'On-time: ${practiceData['prt_budget_ot'] ?? '0'} B',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Late: ${practiceData['prt_budget_late'] ?? '0'} B',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  /// 🔹 **Attendees List**
                  SizedBox(height: 20),
                  Text(
                    "Attendee List",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                  ),
                  _buildAttendeeList(practiceDate), // ✅ แสดงรายชื่อ Attendees

                  /// 🔹 **Delete & Check Button**
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // TODO: Implement Delete Function
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Re-check Function
                        },
                        child: Text("Check"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 **แสดงรายชื่อ Attendees จาก `practice_users`**
  /// 🔹 **แสดงรายชื่อ Attendees จาก `practice_users`**
  /// 🔹 **แสดงรายชื่อ Attendees จาก `practice_users`**
  Widget _buildAttendeeList(DateTime practiceDate) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('practice_users')
          .where('prt_date', isEqualTo: Timestamp.fromDate(practiceDate))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("No attendees joined yet",
              style: TextStyle(fontSize: 14, color: Colors.grey));
        }

        List<DocumentSnapshot> attendeeDocs = snapshot.data!.docs;

        return Column(
          children: attendeeDocs.map((doc) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('user_id', isEqualTo: doc['user_id'])
                  .get()
                  .then((query) => query.docs.isNotEmpty
                      ? query.docs.first.reference.get()
                      : Future.value(null)),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return Container(); // ✅ ถ้าหา user ไม่เจอให้คืนค่าเป็นว่าง
                }

                var userData = userSnapshot.data!;
                String fullName =
                    "${userData['stu_firstname']} ${userData['stu_lastname']}";

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(fullName),
                    leading: Icon(Icons.person, color: Colors.deepOrangeAccent),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
