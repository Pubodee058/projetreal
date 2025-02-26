import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  _savePractice() async {
    if (_titleController.text.isEmpty ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("⚠️ กรุณากรอกข้อมูลให้ครบ!")));
      return;
    }

    await _firestore.collection('pratice').add({
      'prt_title': _titleController.text,
      'prt_date':
          Timestamp.fromDate(widget.selectedDate), // ✅ ล็อควันที่จากปฏิทิน
      'prt_start_time': "${_startTime!.hour}:${_startTime!.minute}",
      'prt_end_time': "${_endTime!.hour}:${_endTime!.minute}",
      'prt_detail': _detailController.text,
      'prt_budget_ot': _budgetOTController.text.isNotEmpty
          ? double.tryParse(_budgetOTController.text)
          : null, // ✅ สามารถเป็น `null`
      'prt_budget_late': _budgetLateController.text.isNotEmpty
          ? double.tryParse(_budgetLateController.text)
          : null, // ✅ สามารถเป็น `null`
      'pay_date': null, // ✅ ตั้งค่าเป็น `null` ไปก่อน
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("✅ บันทึกการฝึกซ้อมเรียบร้อย!")));
    Navigator.pop(context);
  }

  /// 📌 UI ฟอร์ม
  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Practice Date"), backgroundColor: Colors.redAccent),
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
              child: Text("Save"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
