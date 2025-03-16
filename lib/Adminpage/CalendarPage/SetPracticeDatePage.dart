import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/constant.dart';

class SetPracticeDatePage extends StatefulWidget {
  final DateTime selectedDate; // รับวันที่จาก `AdminSchedulePage`

  SetPracticeDatePage({required this.selectedDate});

  @override
  _SetPracticeDatePageState createState() => _SetPracticeDatePageState();
}

class _SetPracticeDatePageState extends State<SetPracticeDatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _budgetLateController = TextEditingController();
  final TextEditingController _budgetOTController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📌 ฟังก์ชันบันทึก `practice`
Future<void> _savePractice() async {
  if (_titleController.text.isEmpty || _startTime == null || _endTime == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("⚠️ Please fill in all information!")));
    return;
  }

  try {
    // ✅ เพิ่มข้อมูลกิจกรรมลง `practice`
    DocumentReference practiceRef = await FirebaseFirestore.instance.collection('pratice').add({
      'prt_title': _titleController.text,
      'prt_date': Timestamp.fromDate(widget.selectedDate),
      'prt_start_time': "${_startTime!.hour}:${_startTime!.minute}",
      'prt_end_time': "${_endTime!.hour}:${_endTime!.minute}",
      'prt_detail': _detailController.text,
      'prt_budget_ot': _budgetOTController.text.isNotEmpty
          ? double.tryParse(_budgetOTController.text)
          : null,
      'prt_budget_late': _budgetLateController.text.isNotEmpty
          ? double.tryParse(_budgetLateController.text)
          : null,
      'pay_date': null,
      'checked': false,
    });

    // ✅ ดึงรายชื่อผู้ใช้ทั้งหมดจาก `users` Collection
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();

    // ✅ เพิ่มผู้ใช้แต่ละคนไปที่ `practice_users`
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var userDoc in userSnapshot.docs) {
      batch.set(FirebaseFirestore.instance.collection('practice_users').doc(), {
        'practice_id': practiceRef.id,
        'prt_date': Timestamp.fromDate(widget.selectedDate),
        'user_id': userDoc['user_id'],
        'stu_firstname': userDoc['stu_firstname'],
        'stu_lastname': userDoc['stu_lastname'],
        'status': 'absent', // ✅ สถานะเริ่มต้น
      });
    }
    await batch.commit();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("✅ Training record completed!")));

    Navigator.pop(context);
  } catch (e) {
    print("❌ Error saving practice: $e");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("❌ Fail to save training session!")));
  }
}

  /// 📌 UI ฟอร์ม
  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Practice Date",style: TextStyle(
        color: Colors.white
      ),), backgroundColor: red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔹 Title
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Practice Title")),

            /// 🔹 ล็อควันที่จากปฏิทิน (เลือกไม่ได้)
            ListTile(
              title: Text(DateFormat('dd / MM / yyyy').format(widget.selectedDate)),
              leading: Icon(Icons.calendar_today, color: Colors.grey), // เปลี่ยนสีให้รู้ว่ากดไม่ได้
            ),

            /// 🔹 Start Time และ End Time
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(_startTime != null ? _startTime!.format(context) : "Start Time"),
                    leading: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (pickedTime != null) setState(() => _startTime = pickedTime);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(_endTime != null ? _endTime!.format(context) : "End Time"),
                    leading: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (pickedTime != null) setState(() => _endTime = pickedTime);
                    },
                  ),
                ),
              ],
            ),

            /// 🔹 Detail
            TextField(controller: _detailController, decoration: InputDecoration(labelText: "Detail")),

            /// 🔹 Budget OT (Optional)
            TextField(controller: _budgetOTController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Budget for on-time person")),

            /// 🔹 Budget Late (Optional)
            TextField(controller: _budgetLateController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Budget for late person")),

            SizedBox(height: 20),

            /// 🔹 ปุ่มบันทึก
            ElevatedButton(
              onPressed: _savePractice,
              child: Text("Save",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: red),
            ),
          ],
        ),
      ),
    );
  }
}
