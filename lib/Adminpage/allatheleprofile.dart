import 'package:flutter/material.dart';
import 'package:myproject/main.dart';

class Allatheleprofile extends StatelessWidget {
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
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // ฟังก์ชันเมื่อกดปุ่ม
                },
                child: Text('ออกรายงานการซ้อม',style: TextStyle(color: Colors.black),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
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
                child: Text('Log out',style: TextStyle(color: Colors.black),),
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
