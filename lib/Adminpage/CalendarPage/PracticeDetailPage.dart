import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Adminpage/CalendarPage.dart';

class PracticeDetailPage extends StatefulWidget {
  final String practiceId;

  PracticeDetailPage({required this.practiceId});

  @override
  _PracticeDetailPageState createState() => _PracticeDetailPageState();
}

class _PracticeDetailPageState extends State<PracticeDetailPage> {
  bool _isChecking = false; // ใช้ตรวจสอบว่ากด Check หรือยัง
  Map<String, String> _updatedStatuses = {}; // เก็บสถานะที่อัปเดตของผู้ใช้

  Future<void> _deletePractice(
      Timestamp prtDate, String startTime, String endTime) async {
    try {
      // 🔸ลบข้อมูลใน collection pratice
      QuerySnapshot practiceQuery = await FirebaseFirestore.instance
          .collection('pratice')
          .where('prt_date', isEqualTo: prtDate)
          .where('prt_start_time', isEqualTo: startTime)
          .where('prt_end_time', isEqualTo: endTime)
          .get();

      // ตรวจสอบก่อนลบ
      if (practiceQuery.docs.isNotEmpty) {
        await practiceQuery.docs.first.reference.delete();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("❌ Practice not found")));
        return;
      }

      // 🔸ลบข้อมูลใน collection practice_users ที่มี prt_date ตรงกัน
      QuerySnapshot practiceUsersQuery = await FirebaseFirestore.instance
          .collection('practice_users')
          .where('prt_date', isEqualTo: prtDate)
          .get();

      for (DocumentSnapshot doc in practiceUsersQuery.docs) {
        await doc.reference.delete();
      }

      // 🔸แจ้งเตือนว่าลบเรียบร้อย
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("✅ Practice and attendees deleted successfully")));

      if (mounted) {
        setState(() {});
      }

      // 🔸กลับไปหน้า Calendar หลังลบเสร็จ
      Navigator.of(context).pop();
    } catch (e) {
      print("Error deleting practice and attendees: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Failed to delete: $e")));
    }
  }

  void _confirmDeleteDialog(
      Timestamp prtDate, String startTime, String endTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this practice?'),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Confirm', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              _deletePractice(prtDate, startTime, endTime); // เรียกฟังก์ชันลบ
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Practice Detail'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pratice')
            .doc(widget.practiceId)
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
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 **Practice Title & Date**
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        practiceData['prt_title'] ?? 'No Title',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          Text(
                            '${DateFormat('dd MMM yyyy').format(practiceDate)}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${practiceData['prt_start_time']} - ${practiceData['prt_end_time']}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
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

                  /// 🔹 **Practice Detail**
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        practiceData['prt_detail'] ?? 'No Description',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  /// 🔹 **Budget Info**
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        'On-time: ${practiceData['prt_budget_ot'] ?? '0'} B',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Spacer(), // ดันข้อความไปทางขวา
                      Text(
                        'Late: ${practiceData['prt_budget_late'] ?? '0'} B',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  /// 🔹 **Attendees List**
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Attendee List",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      ),
                    ],
                  ),
                  _buildAttendeeList(practiceDate),

                  /// 🔹 **Delete & Check Button**
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteDialog(
                          practiceData['prt_date'],
                          practiceData['prt_start_time'],
                          practiceData['prt_end_time'],
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.7,
                        height: size.height * 0.05,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isChecking =
                                  !_isChecking; // กด Check เพื่อเปลี่ยน UI
                            });
                          },
                          child: Text(
                            _isChecking ? "Cancel" : "Check",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  /// 🔹 **Save Button**
                  if (_isChecking)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveStatuses,
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _finishJob,
                      child: Text(
                        "Job Finish",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 **แสดงรายชื่อ Attendees และอัปเดต Status**
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
            String fullName = "${doc['stu_firstname']} ${doc['stu_lastname']}";
            String currentStatus = _updatedStatuses[doc.id] ?? doc['status'];

            return Card(
              color: currentStatus == "absent"
                  ? Colors.red.shade100
                  : Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(
                  fullName,
                  style: TextStyle(
                    color:
                        currentStatus == "absent" ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Icon(Icons.person, color: Colors.deepOrangeAccent),
                trailing: _isChecking
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                _updateTempStatus(doc.id, "absent"),
                          ),
                          ElevatedButton(
                            onPressed: () => _updateTempStatus(doc.id, "late"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentStatus == "late"
                                  ? Colors.red
                                  : Colors.grey[300],
                            ),
                            child: Text(
                              "Late",
                              style: TextStyle(
                                color: currentStatus == "late"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text("Status: $currentStatus"),
              ),
            );
          }).toList(),
        );
      },
    );
  }

 void _finishJob() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // ดึงข้อมูลผู้เข้าร่วมทั้งหมดของ practice นี้
    QuerySnapshot practiceUsers = await firestore
        .collection('practice_users')
        .where('practice_id', isEqualTo: widget.practiceId)
        .get();

    // ดึงข้อมูลของ practice ที่เกี่ยวข้อง
    DocumentSnapshot practiceDoc =
        await firestore.collection('pratice').doc(widget.practiceId).get();

    if (!practiceDoc.exists) {
      print("❌ Practice document not found!");
      return;
    }

    double budgetOT = (practiceDoc['prt_budget_ot'] ?? 0).toDouble();
    double budgetLate = (practiceDoc['prt_budget_late'] ?? 0).toDouble();

    WriteBatch batch = firestore.batch();

    for (var doc in practiceUsers.docs) {
      String userId = doc['user_id'];
      String status = doc['status'];
      String stuFirstName = doc['stu_firstname'];

      // ค้นหาผู้ใช้จากตาราง users ที่มี user_id และ stu_firstname ตรงกัน
      QuerySnapshot userSnapshot = await firestore
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .where('stu_firstname', isEqualTo: stuFirstName)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentReference userRef = userSnapshot.docs.first.reference;

        // อัปเดต allowance ตาม status ของผู้ใช้
        if (status == "on_time") {
          batch.update(userRef, {'allowance': FieldValue.increment(budgetOT)});
        } else if (status == "late") {
          batch.update(userRef, {'allowance': FieldValue.increment(budgetLate)});
        }
      }
    }

    // อัปเดตว่า practice นี้ถูกเช็คเสร็จแล้ว
    batch.update(
        firestore.collection('pratice').doc(widget.practiceId),
        {'checked': true});

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Job Finished Successfully!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  } catch (e) {
    print("❌ Error finishing job: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed to finish job: $e")),
    );
  }
}


  /// 🔹 **ฟังก์ชันอัปเดตค่า `status` ชั่วคราวใน UI**
  void _updateTempStatus(String docId, String status) {
    setState(() {
      _updatedStatuses[docId] = status;
    });
  }

  /// 🔹 **ฟังก์ชันบันทึก `status` กลับไปที่ Firestore**
void _saveStatuses() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    for (var entry in _updatedStatuses.entries) {
      // อัปเดตสถานะของ user ใน practice_users
      await firestore.collection('practice_users').doc(entry.key).update({
        'status': entry.value
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Updated statuses successfully!"))
    );

    setState(() {
      _isChecking = false;
      _updatedStatuses.clear();
    });

  } catch (e) {
    print("❌ Error saving statuses: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed to save statuses: $e"))
    );
  }
}


//   Future<void> _updateAllowance() async {
//   try {
//     for (var entry in _updatedStatuses.entries) {
//       String docId = entry.key;
//       String newStatus = entry.value;

//       // ✅ ดึงข้อมูลจาก `practice_users`
//       DocumentSnapshot practiceUserDoc = await FirebaseFirestore.instance
//           .collection('practice_users')
//           .doc(docId)
//           .get();

//       if (!practiceUserDoc.exists) continue;

//       String userId = practiceUserDoc['user_id']; // 🔹 หาว่าเป็น User ไหน
//       String practiceId = practiceUserDoc['practice_id']; // 🔹 หาว่าเป็นกิจกรรมไหน

//       // ✅ ดึงข้อมูลจาก `pratice`
//       DocumentSnapshot practiceDoc = await FirebaseFirestore.instance
//           .collection('pratice')
//           .doc(practiceId)
//           .get();

//       if (!practiceDoc.exists) continue;

//       double allowanceToAdd = 0.0;
//       if (newStatus == "on_time") {
//         allowanceToAdd = (practiceDoc['prt_budget_ot'] ?? 0).toDouble();
//       } else if (newStatus == "late") {
//         allowanceToAdd = (practiceDoc['prt_budget_late'] ?? 0).toDouble();
//       }

//       if (allowanceToAdd > 0) {
//         // ✅ อัปเดต allowance ของ User
//         DocumentReference userRef =
//             FirebaseFirestore.instance.collection('users').doc(userId);

//         await FirebaseFirestore.instance.runTransaction((transaction) async {
//           DocumentSnapshot userDoc = await transaction.get(userRef);
//           if (userDoc.exists) {
//             double currentAllowance = (userDoc['allowance'] ?? 0).toDouble();
//             transaction.update(userRef, {
//               'allowance': currentAllowance + allowanceToAdd,
//             });
//           }
//         });
//       }
//     }
//   } catch (e) {
//     print("❌ Error updating allowance: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("❌ Failed to update allowance.")),
//     );
//   }
// }
}
