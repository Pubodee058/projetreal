import 'package:flutter/material.dart';

class Summarypracuserpage extends StatefulWidget {
  @override
  _SummarypracuserpageState createState() => _SummarypracuserpageState();
}

class _SummarypracuserpageState extends State<Summarypracuserpage> {
  // Mockup Data for Credit Earned
  List<Map<String, String>> creditEarned = [
    {
      'title': 'Practice item',
      'date': '16 Dec 24 15:00 - 15:30',
      'status': 'On time',
      'credit': '20 B',
    },
    {
      'title': 'Practice item',
      'date': '16 Dec 24 15:00 - 15:30',
      'status': 'Late',
      'credit': '10 B',
    },
    {
      'title': 'Practice item',
      'date': '16 Dec 24 15:00 - 15:30',
      'status': 'Missed',
      'credit': '-',
    },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Credit Section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Total Credit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '200 Baht',
              style: TextStyle(fontSize: 32, color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Credit Earned Section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Credit Earned',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: creditEarned.map((practice) {
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(practice['title'] ?? 'No Title'),
                      subtitle: Text(
                        '${practice['date']} - ${practice['status']}',
                        style: TextStyle(color: practice['status'] == 'On time' ? Colors.green : (practice['status'] == 'Late' ? Colors.orange : Colors.red)),
                      ),
                      trailing: Text(
                        practice['credit'] ?? '-',
                        style: TextStyle(color: practice['status'] == 'On time' ? Colors.green : (practice['status'] == 'Late' ? Colors.orange : Colors.red)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}