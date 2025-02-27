import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    DocumentSnapshot doc = await _firestore.collection('pratice').doc(widget.practiceId).get();
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
      var userDoc = await _firestore.collection('users').doc(doc['user_id']).get();
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
        appBar: AppBar(title: Text("Practice Detail"), backgroundColor: Colors.redAccent),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Practice Detail"), backgroundColor: Colors.redAccent),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Title + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  practiceData!['prt_title'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(DateFormat('dd MMM yyyy').format((practiceData!['prt_date'] as Timestamp).toDate())),
                    SizedBox(width: 5),
                    Icon(Icons.edit, color: Colors.brown), // ไว้รองรับฟังก์ชันอัปเดต
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
            Text(
              practiceData!['prt_detail'],
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),

            /// 🔹 Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("On-time: ${practiceData!['prt_budget_ot']} B"),
                Text("Late: ${practiceData!['prt_budget_late']} B"),
              ],
            ),
            SizedBox(height: 20),

            /// 🔹 Attendee List
            Text(
              "Attendee List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 10),

            attendees.isEmpty
                ? Text("No attendees yet.", style: TextStyle(color: Colors.grey))
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
                          ),
                          child: Text(attendee['name']),
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
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // ✅ ฟังก์ชันลบจะเพิ่มภายหลัง
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // ✅ ฟังก์ชัน Recheck จะเพิ่มภายหลัง
                  },
                  child: Text("Check"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
