import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {
  final DateTime selectedDate;

  EventPage({required this.selectedDate});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ตั้งค่าของวันที่ในฟอร์มให้เป็นวันที่ที่เลือกจากหน้า Calendar
    dateController.text = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
  }

  // ฟังก์ชันเปิด TimePicker
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      controller.text =
          selectedTime.format(context); // แสดงเวลาที่เลือกใน TextFormField
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make an Announcement'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Title
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'New Announcement',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Set Date (Auto-filled from the Calendar)
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Set date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16),

              // Time Picker for Start time and End time
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(
                          context, startTimeController), // เปิด TimePicker
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: startTimeController,
                          decoration: InputDecoration(
                            labelText: 'Start time',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('to'),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(
                          context, endTimeController), // เปิด TimePicker
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: endTimeController,
                          decoration: InputDecoration(
                            labelText: 'End time',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Detail
              TextFormField(
                controller: detailController,
                decoration: InputDecoration(
                  labelText: 'Detail',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Save button
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    Navigator.pop(context, {
                      'title': titleController.text,
                      'date': widget.selectedDate,
                      'start_time': startTimeController.text,
                      'end_time': endTimeController.text,
                      'detail': detailController.text,
                      'type': 'Event',
                    });
                  } else {
                    // แสดงข้อความเตือนถ้า title ไม่ได้กรอก
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Title is required!'),
                    ));
                  }
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}