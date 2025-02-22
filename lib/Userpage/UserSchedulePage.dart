import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Userpage/PracticeuserDetailPage.dart';
import 'package:myproject/Userpage/eventuserdetail.dart';

DateTime _parseDate(String dateString) {
  try {
    // รูปแบบวันที่ที่คุณมี เช่น "16 Dec 24 15:00 - 15:30"
    final DateFormat formatter = DateFormat('dd MMM yy HH:mm - HH:mm');
    // ใช้ formatter.parse() แปลงเป็น DateTime
    return formatter.parse(dateString);
  } catch (e) {
    // หากเกิดข้อผิดพลาด, คืนค่า DateTime ปัจจุบัน
    print('Error parsing date: $e');
    return DateTime.now();
  }
}

class UserSchedulePage extends StatefulWidget {
  @override
  _UserSchedulePageState createState() => _UserSchedulePageState();
}

class _UserSchedulePageState extends State<UserSchedulePage> {
  List<Map<String, String>> todayPractice = [
    {
      'title': 'Practice item',
      'date': '16 Dec 24 15:00 - 15:30',
      'description': 'Supporting line text lorem ipsum dolor sit amet,...',
    },
  ];

  List<Map<String, String>> announcements = [
    {
      'title': 'Event item',
      'date': '16 Dec 24 15:00 - 15:30',
      'description': 'Supporting line text lorem ipsum dolor sit amet,...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          // Today’s Practice Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Today’s Practice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...todayPractice.map((practice) {
            return Card(
              elevation: 1,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(Icons.access_time, color: Colors.deepOrangeAccent),
                title: Text(practice['title'] ?? 'No Title'),
                subtitle: Text(
                    '${DateFormat('dd MMM yy').format(_parseDate(practice['date']!))} ${practice['description']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PracticeuserDetailPage( // หน้า PracticeDetailPage
                          event: practice, // ส่งข้อมูลที่เป็น Map<String, String>
                          // ส่งรายชื่อผู้เข้าร่วมกิจกรรม
                        ),
                      ),
                    );
                  },
                  child: Text('Join'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
                ),
              ),
            );
          }).toList(),

          // Announcement Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Announcement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...announcements.map((announcement) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventuserDetailPage(event: announcement),
                    ),
                  );
              },
              child: Card(
                elevation: 1,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.announcement, color: Colors.redAccent),
                  title: Text(announcement['title'] ?? 'No Title'),
                  subtitle: Text(
                      '${DateFormat('dd MMM yy').format(_parseDate(announcement['date']!))} ${announcement['description']}'),
                ),
                
              ),
            );
          }),
        ],
      ),
    );
  }
}