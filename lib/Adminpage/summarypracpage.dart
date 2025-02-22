import 'package:flutter/material.dart';

class Summarypracpage extends StatelessWidget {
   final List<Map<String, dynamic>> paymentSummary = [
    {
      'date': '30 Dec 24',
      'amount': '2000 B',
      'attendees': 15,
    },
    // สามารถเพิ่มข้อมูลเพิ่มเติมได้ตามต้องการ
  ];

  final List<Map<String, dynamic>> history = [
    {
      'item': 'Practice item',
      'date': '16 Dec 24',
      'time': '15:00 - 15:30',
      'attendees': 15,
    },
    {
      'item': 'Practice item',
      'date': '17 Dec 24',
      'time': '16:00 - 16:30',
      'attendees': 15,
    },
    {
      'item': 'Practice item',
      'date': '18 Dec 24',
      'time': '17:00 - 17:30',
      'attendees': 15,
    },
    // สามารถเพิ่มข้อมูลเพิ่มเติมได้ตามต้องการ
  ];
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice History'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Payment Summary Section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  // วนลูปข้อมูล Payment Summary
                  ...paymentSummary.map((payment) {
                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(payment['date']),
                        subtitle: Text('Total ${payment['attendees']} Attendee'),
                        trailing: Text(payment['amount']),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            // History Section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  // วนลูปข้อมูล History
                  ...history.map((event) {
                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text(event['item']),
                        subtitle: Text('${event['date']} ${event['time']}'),
                        trailing: Text('${event['attendees']} Attendee'),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}