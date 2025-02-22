import 'package:flutter/material.dart';

class PracticeDetailPage extends StatelessWidget {
  final Map<String, String> event;
  final List<String> attendees; // สมมุติว่า 'attendees' คือรายชื่อผู้เข้าร่วมกิจกรรม

  // Constructor รับค่าจากหน้าเดิม
  PracticeDetailPage({required this.event, required this.attendees});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice History Detail'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'] ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Time: ${event['time']}'),
              SizedBox(height: 16),
              Text(
                event['description'] ?? 'No Description',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              // Text('Attendees: ${attendees.join(", ")}'), // แสดงรายชื่อผู้เข้าร่วม
            ],
          ),
        ),
      ),
    );
  }
}