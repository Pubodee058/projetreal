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
  bool _isChecking = false; // ใช้ตรวจสอบว่ากด Check หรือยัง
  Map<String, String> _updatedStatuses = {}; // เก็บสถานะที่อัปเดตของผู้ใช้

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _buildAttendeeList(practiceDate),

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
                          setState(() {
                            _isChecking = !_isChecking; // กด Check เพื่อเปลี่ยน UI
                          });
                        },
                        child: Text(_isChecking ? "Cancel" : "Check"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),

                  /// 🔹 **Save Button**
                  if (_isChecking)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveStatuses,
                        child: Text("Save"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
                    color: currentStatus == "absent" ? Colors.red : Colors.black,
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

  /// 🔹 **ฟังก์ชันอัปเดตค่า `status` ชั่วคราวใน UI**
  void _updateTempStatus(String docId, String status) {
    setState(() {
      _updatedStatuses[docId] = status;
    });
  }

  /// 🔹 **ฟังก์ชันบันทึก `status` กลับไปที่ Firestore**
  void _saveStatuses() async {
    for (var entry in _updatedStatuses.entries) {
      await FirebaseFirestore.instance
          .collection('practice_users')
          .doc(entry.key)
          .update({'status': entry.value});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Updated status successfully!")),
    );

    setState(() {
      _isChecking = false;
      _updatedStatuses.clear();
    });
  }
}
