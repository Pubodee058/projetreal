import 'package:flutter/material.dart';
import 'package:myproject/Userpage/UserSchedulePage.dart';
import 'package:myproject/Userpage/profileuserpage.dart';
import 'package:myproject/Userpage/summaryparcpage.dart';
import 'package:myproject/constant.dart';

class Mainuserpage extends StatefulWidget {
  @override
  _MainuserpageState createState() => _MainuserpageState();
}

class _MainuserpageState extends State<Mainuserpage> {
  int _currentIndex = 0;

  // รายการหน้าในแต่ละแท็บ
  final List<Widget> _pages = [
    UserSchedulePage(),
    UserPracticeHistoryPage(),
    Profileuserpage()
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
        selectedItemColor: red,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Training Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_basketball),
            label: 'Training History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}