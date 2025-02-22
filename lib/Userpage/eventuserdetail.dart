import 'package:flutter/material.dart';

class EventuserDetailPage extends StatelessWidget {
  final Map<String, String> event;

  // Constructor รับข้อมูลจากหน้า Event
  EventuserDetailPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement Detail'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อกิจกรรม (Event Item)
            Text(
              event['title'] ?? 'No Title',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 10),

            // วันที่และเวลา
            Text(
              '${event['date']} ${event['time']}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),

            // รายละเอียดกิจกรรม
            Text(
              event['description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),

            // ข้อมูลสรุปการจ่ายเงิน (ถ้ามี)
            Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Amount: 2000 B'),
            SizedBox(height: 10),
            Text('Total Attendees: 15'),
          ],
        ),
      ),
    );
  }
}