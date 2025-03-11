import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/constant.dart';

class UserPracticeHistoryPage extends StatefulWidget {
  @override
  _UserPracticeHistoryPageState createState() =>
      _UserPracticeHistoryPageState();
}

class _UserPracticeHistoryPageState extends State<UserPracticeHistoryPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? stuFirstName;
  String? stuLastName;
  double totalCredit = 0.0; // 🏆 ตัวแปรเก็บค่า allowance
  List<Map<String, dynamic>> practiceHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// 📌 ดึงข้อมูลชื่อจริง, นามสกุล และ Allowance ของ User
  Future<void> _fetchUserData() async {
    if (user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user!.uid).get();

    if (userDoc.exists && mounted) {
      // ✅ เช็ค mounted ก่อนเรียก setState()
      setState(() {
        stuFirstName = userDoc['stu_firstname'];
        stuLastName = userDoc['stu_lastname'];
        totalCredit = (userDoc['allowance'] ?? 0).toDouble();
      });

      _fetchPracticeHistory();
    }
  }

  Future<void> _fetchPracticeHistory() async {
    if (stuFirstName == null || stuLastName == null) return;

    QuerySnapshot query = await _firestore
        .collection('practice_users')
        .where('stu_firstname', isEqualTo: stuFirstName)
        .where('stu_lastname', isEqualTo: stuLastName)
        .orderBy('prt_date', descending: true)
        .get();

    List<Map<String, dynamic>> fetchedData = await Future.wait(
      query.docs.map((doc) async {
        DocumentSnapshot practiceDoc = await _firestore
            .collection('pratice')
            .doc(doc['practice_id'])
            .get();
        return {
          'title': practiceDoc.exists
              ? practiceDoc['prt_title']
              : 'Unknown Practice',
          'date': (doc['prt_date'] as Timestamp).toDate(),
          'start_time':
              practiceDoc.exists ? practiceDoc['prt_start_time'] : 'N/A',
          'end_time': practiceDoc.exists ? practiceDoc['prt_end_time'] : 'N/A',
          'status': doc['status'],
        };
      }).toList(),
    );

    if (mounted) {
      // ✅ เช็ค mounted ก่อนเรียก setState()
      setState(() {
        practiceHistory = fetchedData;
      });
    }
  }

  /// 📌 ฟังก์ชันกำหนดสีของการ์ดตาม `status`
  Color _getCardColor(String status) {
    switch (status) {
      case 'on_time':
        return Colors.green[100]!; // สีเขียวอ่อน
      case 'late':
        return Colors.orange[100]!; // สีเหลืองอ่อน
      case 'absent':
        return Colors.red[100]!; // สีแดงอ่อน
      default:
        return Colors.grey[200]!; // สีเทาสำหรับค่าที่ไม่รู้จัก
    }
  }

  /// 📌 ฟังก์ชันกำหนดสีของตัวอักษรตาม `status`
  Color _getTextColor(String status) {
    switch (status) {
      case 'on_time':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice History',style: TextStyle(color: Colors.white),),
        backgroundColor: red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 **Header: Total Credit**
            Text(
              "Total Credit",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "${totalCredit.toStringAsFixed(0)} Baht", // ✅ แสดงค่า allowance
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: red),
            ),

            SizedBox(height: 16),

            /// 🔹 **Header: Credit Earned**
            Text(
              "Credit Earned",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            /// 🔹 **แสดงประวัติการเข้าร่วม**
            Expanded(
              child: practiceHistory.isEmpty
                  ? Center(child: Text("No practice history available."))
                  : ListView.builder(
                      itemCount: practiceHistory.length,
                      itemBuilder: (context, index) {
                        var practice = practiceHistory[index];
                        return Card(
                          color: _getCardColor(
                              practice['status']), // เปลี่ยนสีการ์ดตาม `status`
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(practice['title']),
                            subtitle: Text(
                              "${DateFormat('dd MMM yy').format(practice['date'])} "
                              "${practice['start_time']} - ${practice['end_time']}  ",
                              style: TextStyle(
                                  color: _getTextColor(
                                      practice['status'])), // เปลี่ยนสีตัวอักษร
                            ),
                            trailing: Text(
                              practice['status'] == 'on_time'
                                  ? "✅"
                                  : practice['status'] == 'late'
                                      ? "⚠️"
                                      : "❌",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
