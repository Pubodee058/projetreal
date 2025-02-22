import 'package:flutter/material.dart';
import 'package:myproject/main.dart';

class Allatheleprofile extends StatelessWidget {
  final List<Map<String, dynamic>> paidList = [
    {
      'date': '30 Dec 24',
      'amount': '2000 B',
      'attendees': 15,
    },
    {
      'date': '31 Dec 24',
      'amount': '2500 B',
      'attendees': 20,
    },
    // สามารถเพิ่มข้อมูลได้ตามต้องการ
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ส่วน Paid List
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paid List',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  // วนลูปข้อมูล Paid List
                  ...paidList.map((payment) {
                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(payment['date']),
                        subtitle:
                            Text('Total ${payment['attendees']} Attendee'),
                        trailing: Text(payment['amount']),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            // ปุ่ม Log out อยู่ในส่วนของ body
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // ฟังก์ชันเมื่อกดปุ่ม Log out
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginPage()), // คุณต้องสร้างหน้า LoginPage
                  );
                },
                child: Text('Log out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
            // คุณสามารถเพิ่มส่วนอื่น ๆ เช่น Profile, Settings ฯลฯ ที่คุณต้องการ
          ],
        ),
      ),
    );
  }
}