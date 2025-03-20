import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/constant.dart';

class PracticeUserDetailPage extends StatefulWidget {
  final String practiceId;

  PracticeUserDetailPage({required this.practiceId});

  @override
  _PracticeUserDetailPageState createState() => _PracticeUserDetailPageState();
}

class _PracticeUserDetailPageState extends State<PracticeUserDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? practiceData;

  bool isJoined = false;
  bool isCheckingJoinStatus = true;

  @override
  void initState() {
    super.initState();
    _fetchPracticeData();
  }

  /// 📌 โหลดข้อมูล practice
  Future<void> _fetchPracticeData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('pratice')
          .doc(widget.practiceId)
          .get();

      if (!doc.exists) {
        print("❌ Practice not found");
        Navigator.pop(context);
        return;
      }

      setState(() {
        practiceData = doc.data() as Map<String, dynamic>;
        isLoading = false;
      });

      // 🔹 เช็คสถานะ Join
      _checkUserJoinStatus();
    } catch (e) {
      print("❌ Error fetching practice: $e");
      Navigator.pop(context);
    }
  }

  /// 📌 เช็คสถานะว่าผู้ใช้ Join หรือยัง
  Future<void> _checkUserJoinStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception("User doc not found");
      String firstName = userDoc['stu_firstname'];
      String lastName = userDoc['stu_lastname'];

      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('practice_users')
          .where('practice_id', isEqualTo: widget.practiceId)
          .where('stu_firstname', isEqualTo: firstName)
          .where('stu_lastname', isEqualTo: lastName)
          .where('status', isEqualTo: 'on_time')
          .get();

      setState(() {
        isJoined = query.docs.isNotEmpty;
        isCheckingJoinStatus = false;
      });
    } catch (e) {
      print("❌ Error checking user join status: $e");
      setState(() {
        isCheckingJoinStatus = false;
      });
    }
  }

  /// 📌 Join
  Future<void> _joinPractice() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String firstName = userDoc['stu_firstname'];
      String lastName = userDoc['stu_lastname'];

      // 🔹 หาว่าเคยอยู่ใน practice_users หรือเปล่า
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('practice_users')
          .where('practice_id', isEqualTo: widget.practiceId)
          .where('stu_firstname', isEqualTo: firstName)
          .where('stu_lastname', isEqualTo: lastName)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'status': 'on_time'});
      }

      setState(() {
        isJoined = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Joined successfully!"))
      );

      // 🔹 เมื่อจบ → ส่ง result='updated' กลับไป
      Navigator.pop(context, 'updated');

    } catch (e) {
      print("❌ Error join practice: $e");
    }
  }

  /// 📌 Cancel
  Future<void> _cancelPractice() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String firstName = userDoc['stu_firstname'];
      String lastName = userDoc['stu_lastname'];

      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('practice_users')
          .where('practice_id', isEqualTo: widget.practiceId)
          .where('stu_firstname', isEqualTo: firstName)
          .where('stu_lastname', isEqualTo: lastName)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'status': 'absent'});
      }

      setState(() {
        isJoined = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Canceled successfully!"))
      );

      // 🔹 ส่ง result='updated' กลับ
      Navigator.pop(context, 'updated');

    } catch (e) {
      print("❌ Error cancel practice: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Practice Detail"), backgroundColor: red),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    DateTime prtDate = (practiceData!['prt_date'] as Timestamp).toDate();
    String title = practiceData!['prt_title'] ?? 'No Title';
    String detail = practiceData!['prt_detail'] ?? 'No Detail';
    String startTime = practiceData!['prt_start_time'] ?? '';
    String endTime = practiceData!['prt_end_time'] ?? '';
    double budgetOt = practiceData!['prt_budget_ot']?.toDouble() ?? 0;
    double budgetLate = practiceData!['prt_budget_late']?.toDouble() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Practice Detail"),
        backgroundColor: red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(prtDate),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$startTime - $endTime",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 16),

            /// Detail
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(detail, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 16),

            /// Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("On-time: ${budgetOt.toStringAsFixed(0)} B",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Late: ${budgetLate.toStringAsFixed(0)} B",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Spacer(),

            /// Join/Cancel Button
            if (isCheckingJoinStatus)
              CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!isJoined) {
                      _joinPractice();
                    } else {
                      _cancelPractice();
                    }
                  },
                  child: Text(isJoined ? "Cancel" : "Join",style: TextStyle(
                    color: Colors.white
                  ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined ? Colors.grey : red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
