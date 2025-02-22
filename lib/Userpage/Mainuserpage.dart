import 'package:flutter/material.dart';

class Mainuserpage extends StatefulWidget {
  @override
  _MainuserpageState createState() => _MainuserpageState();
}

class _MainuserpageState extends State<Mainuserpage> {
  int _currentIndex = 0;

  // รายการหน้าในแต่ละแท็บ
  final List<Widget> _pages = [
    // UserSchedulePage(),
    // Summarypracuserpage(),
    // Profileuserpage()
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'ตารางฝึกซ้อม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_basketball),
            label: 'ยอดการซ้อม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'การตั้งค่า',
          ),
        ],
      ),
    );
  }
}