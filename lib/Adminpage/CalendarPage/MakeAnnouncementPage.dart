import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Adminpage/CalendarPage.dart';
import 'package:myproject/constant.dart';

class MakeAnnouncementPage extends StatefulWidget {
  final DateTime selectedDate; // รับวันที่ที่เลือกมาจาก `AdminSchedulePage`

  MakeAnnouncementPage({required this.selectedDate});

  @override
  _MakeAnnouncementPageState createState() => _MakeAnnouncementPageState();
}

class _MakeAnnouncementPageState extends State<MakeAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📌 ฟังก์ชันบันทึก `announcement`
  _saveAnnouncement() async {
  if (_titleController.text.isEmpty || _startTime == null || _endTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please fill in all information!")));
    return;
  }

  try {
    await _firestore.collection('Announcement').add({
      'ann_title': _titleController.text,
      'ann_date': Timestamp.fromDate(widget.selectedDate),
      'ann_start_time': "${_startTime!.hour}:${_startTime!.minute}",
      'ann_end_time': "${_endTime!.hour}:${_endTime!.minute}",
      'ann_detail': _detailController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Create announcement successful!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Unable to create announcement: $e")));
  }
}


  /// 📌 UI ฟอร์ม
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Make an Announcement",style: TextStyle(
        color: Colors.white
      ),), backgroundColor: red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔹 Title
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Announcement Title")),

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

            SizedBox(height: 20),

            /// 🔹 ปุ่มบันทึก
            ElevatedButton(
              onPressed: _saveAnnouncement,
              child: Text("Save",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: red),
            ),
          ],
        ),
      ),
    );
  }
}
