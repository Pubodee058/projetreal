import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PracticePage extends StatefulWidget {
  final DateTime selectedDate;

  PracticePage({required this.selectedDate});

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController onTimeBudgetController = TextEditingController();
  TextEditingController lateTimeBudgetController = TextEditingController();
  TextEditingController paymentDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ตั้งค่าของวันที่ในฟอร์มให้เป็นวันที่ที่เลือกจากหน้า Calendar
    dateController.text = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
  }

  // ฟังก์ชันเปิด TimePicker
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      controller.text = selectedTime.format(context);  // แสดงเวลาที่เลือกใน TextFormField
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Practice Date'),
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
                  labelText: 'New Practice Session',
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
                      onTap: () => _selectTime(context, startTimeController), // เปิด TimePicker
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
                      onTap: () => _selectTime(context, endTimeController), // เปิด TimePicker
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

              // Budget for on-time person
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: onTimeBudgetController,
                      decoration: InputDecoration(
                        labelText: 'Budget for on-time person',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('B'),
                ],
              ),
              SizedBox(height: 16),

              // Budget for late person
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: lateTimeBudgetController,
                      decoration: InputDecoration(
                        labelText: 'Budget for late person',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('B'),
                ],
              ),
              SizedBox(height: 16),

              // Payment date
              TextFormField(
                controller: paymentDateController,
                decoration: InputDecoration(
                  labelText: 'Set payment date',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      ) ?? DateTime.now();
                      paymentDateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
                    },
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16),

              // Save button
              ElevatedButton(
                onPressed: () {
                  // ส่งข้อมูลกลับไปที่ CalendarPage
                  Navigator.pop(context, {
                    'title': titleController.text,
                    'date': widget.selectedDate,
                    'start_time': startTimeController.text,
                    'end_time': endTimeController.text,
                    'detail': detailController.text,
                    'type': 'Practice', // ประเภทกิจกรรม
                  });
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}