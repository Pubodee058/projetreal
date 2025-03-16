import 'package:flutter/material.dart';
import 'package:myproject/Adminpage/CalendarPage.dart';
import 'package:myproject/Adminpage/allatheleprofile.dart';
import 'package:myproject/Adminpage/summarypracpage.dart';
import 'package:myproject/constant.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  // รายการหน้าในแต่ละแท็บ
  final List<Widget> _pages = [
    CalendarPage(), 
    Summarypracpage(),
    Allatheleprofile()
  ];

  // เปลี่ยนแท็บ
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // แสดงหน้าตามแท็บที่เลือก
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: red, // สีของไอคอนที่เลือก
        unselectedItemColor: Colors.black54, // สีของไอคอนที่ไม่ได้เลือก
        backgroundColor: Colors.white, // พื้นหลังแถบเมนู
        type: BottomNavigationBarType.fixed, // ทำให้ไอคอนไม่ขยับ
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            activeIcon: _buildSelectedIcon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            activeIcon: _buildSelectedIcon(Icons.star_border),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: _buildSelectedIcon(Icons.person),
            label: 'Report',
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างไอคอนที่ถูกเลือก
  Widget _buildSelectedIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50, // สีพื้นหลังไอคอนที่ถูกเลือก
        borderRadius: BorderRadius.circular(20), // ทำให้เป็นวงรี
      ),
      child: Icon(icon, color: red), // ไอคอนสีแดงเมื่อถูกเลือก
    );
  }
}
