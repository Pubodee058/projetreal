import 'package:flutter/material.dart';

class PracticeDetailPage extends StatelessWidget {
final Map<String, String> event; // รับข้อมูลกิจกรรม
  final List<String> attendees; // รับรายชื่อผู้เข้าร่วม

  PracticeDetailPage({required this.event, required this.attendees});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['title'] ?? 'No Title'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'] ?? 'No Title',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              event['date'] ?? 'No Date',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              event['description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // แสดงรายชื่อผู้เข้าร่วม
            Text(
              'Attendees: ${attendees.join(', ')}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}