import 'package:flutter/material.dart';

class PracticeuserDetailPage extends StatefulWidget {
  final Map<String, String> event;

  // Constructor รับข้อมูลกิจกรรม
  PracticeuserDetailPage({required this.event});

  @override
  _PracticeuserDetailPageState createState() => _PracticeuserDetailPageState();
}

class _PracticeuserDetailPageState extends State<PracticeuserDetailPage> {
  bool isJoined = false; // ใช้เพื่อเก็บสถานะของปุ่ม Join
  String buttonText = 'Join'; // ข้อความปุ่ม
  Icon buttonIcon = Icon(Icons.access_time); // ไอคอนปุ่ม

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Detail'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อกิจกรรม (Practice Item)
            Text(
              widget.event['title'] ?? 'No Title',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 10),

            // วันที่และเวลา
            Text(
              '${widget.event['date']} ${widget.event['time']}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),

            // รายละเอียดกิจกรรม
            Text(
              widget.event['description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // ข้อมูลสรุปการจ่ายเงิน
            Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Amount: 2000 B'),
            SizedBox(height: 10),
            Text('Total Attendees: 15'),
            SizedBox(height: 30),

            // สรุปการเข้าร่วม
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('On-time: 00 B'),
                Text('Late: 00 B'),
              ],
            ),
            SizedBox(height: 20),

            // ปุ่ม Join สำหรับเข้าร่วมกิจกรรม
            ElevatedButton.icon(
              onPressed: isJoined
                  ? null // ถ้ากดแล้ว, ไม่สามารถกดปุ่มได้
                  : () {
                      // Logic when user clicks the Join button
                      setState(() {
                        isJoined = true;
                        buttonText = 'Joined';
                        buttonIcon = Icon(Icons.check, color: Colors.white);
                      });

                      // แสดงข้อความ SnackBar หลังจาก 1 วินาที
                      Future.delayed(Duration(seconds: 1), () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Successfully joined the practice!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      });
                    },
              icon: buttonIcon,
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}