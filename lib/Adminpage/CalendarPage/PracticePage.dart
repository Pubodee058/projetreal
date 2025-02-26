import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PracticePage extends StatefulWidget {
  final DateTime selectedDate;

  PracticePage({required this.selectedDate});

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _budgetLateController = TextEditingController();
  final TextEditingController _budgetOTController = TextEditingController();
  DateTime? _payDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  /// 📌 บันทึกข้อมูลและส่งกลับไปยัง `CalendarPage`
  void _savePractice() {
    String title = _titleController.text;
    String detail = _detailController.text;

    if (title.isEmpty || detail.isEmpty || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ กรุณากรอกข้อมูลให้ครบ!")),
      );
      return;
    }

    Map<String, dynamic> practiceData = {
      'prt_title': title,
      'prt_detail': detail,
      'prt_date': widget.selectedDate.toIso8601String(),
      'prt_start_time': _startTime != null
          ? "${_startTime!.hour}:${_startTime!.minute}"
          : null,
      'prt_end_time': _endTime != null
          ? "${_endTime!.hour}:${_endTime!.minute}"
          : null,
      'pay_date': _payDate?.toIso8601String(), // ✅ อนุญาตให้เป็น `null`
      'prt_budget_late': _budgetLateController.text.isNotEmpty
          ? double.tryParse(_budgetLateController.text)
          : null, // ✅ ถ้าว่างให้เป็น `null`
      'prt_budget_ot': _budgetOTController.text.isNotEmpty
          ? double.tryParse(_budgetOTController.text)
          : null, // ✅ ถ้าว่างให้เป็น `null`
    };

    Navigator.pop(context, practiceData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เพิ่มการฝึกซ้อม")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "ชื่อการฝึกซ้อม"),
            ),
            TextField(
              controller: _detailController,
              decoration: InputDecoration(labelText: "รายละเอียด"),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text("เวลาเริ่ม: ${_startTime?.format(context) ?? 'ไม่ระบุ'}"),
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () async {
                    TimeOfDay? pickedTime =
                        await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text("เวลาสิ้นสุด: ${_endTime?.format(context) ?? 'ไม่ระบุ'}"),
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () async {
                    TimeOfDay? pickedTime =
                        await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (pickedTime != null) {
                      setState(() {
                        _endTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _budgetLateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "งบประมาณล่าช้า (เว้นว่างได้)"),
            ),
            TextField(
              controller: _budgetOTController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "งบประมาณ OT (เว้นว่างได้)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePractice,
              child: Text("บันทึก"),
            ),
          ],
        ),
      ),
    );
  }
}
