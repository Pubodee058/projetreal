import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/constant.dart';

class PracticeDetailPage extends StatefulWidget {
  final String practiceId;

  PracticeDetailPage({required this.practiceId});

  @override
  _PracticeDetailPageState createState() => _PracticeDetailPageState();
}

class _PracticeDetailPageState extends State<PracticeDetailPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? practiceData;
  List<Map<String, dynamic>> attendees = [];

  @override
  void initState() {
    super.initState();
    _fetchPracticeDetails();
    _fetchAttendees();
  }

  /// 📌 ดึงข้อมูลของ `Practice`
  Future<void> _fetchPracticeDetails() async {
    DocumentSnapshot doc =
        await _firestore.collection('pratice').doc(widget.practiceId).get();
    if (doc.exists) {
      setState(() {
        practiceData = doc.data() as Map<String, dynamic>;
      });
    }
  }

  /// 📌 ดึงรายชื่อ `Attendee List`
  Future<void> _fetchAttendees() async {
    QuerySnapshot snapshot = await _firestore
        .collection('practice_users')
        .where('prt_id', isEqualTo: widget.practiceId)
        .get();

    List<Map<String, dynamic>> attendeeList = [];
    for (var doc in snapshot.docs) {
      var userDoc =
          await _firestore.collection('users').doc(doc['user_id']).get();
      if (userDoc.exists) {
        attendeeList.add({
          'name': "${userDoc['stu_firstname']} ${userDoc['stu_lastname']}",
        });
      }
    }

    setState(() {
      attendees = attendeeList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (practiceData == null) {
      return Scaffold(
        appBar: AppBar(
            title: Text("Practice Detail"), backgroundColor: red),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Practice Detail"),
        backgroundColor: red, // สีแดงเข้ม
        elevation: 0, // ลบเงา
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Title + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  practiceData!['prt_title'],
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: red),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(
                          (practiceData!['prt_date'] as Timestamp).toDate()),
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.edit,
                        color: Colors.brown), // ไว้รองรับฟังก์ชันอัปเดต
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              "${practiceData!['prt_start_time']} - ${practiceData!['prt_end_time']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            /// 🔹 Description
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                practiceData!['prt_detail'],
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 10),

            /// 🔹 Budget
            Row(
              children: [
                Expanded(
                  child: Text("On-time: ${practiceData!['prt_budget_ot']} B"),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text("Late: ${practiceData!['prt_budget_late']} B"),
                ),
              ],
            ),

            SizedBox(height: 20),

            /// 🔹 Attendee List
            Text(
              "Attendee List",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: red),
            ),
            SizedBox(height: 10),

            attendees.isEmpty
                ? Text("No attendees yet.",
                    style: TextStyle(color: Colors.grey))
                : Column(
                    children: attendees.map((attendee) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 3,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(attendee['name'],
                              style: TextStyle(fontSize: 16)),
                        ),
                      );
                    }).toList(),
                  ),

            Spacer(),

            /// 🔹 Delete & Recheck Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: red),
                  onPressed: () {
                    // ✅ ฟังก์ชันลบจะเพิ่มภายหลัง
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // ✅ ฟังก์ชัน Recheck จะเพิ่มภายหลัง
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    "Check",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
