import 'package:flutter/material.dart';

class Profileuserpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture and Name
            Container(
              width: 100, // กำหนดขนาดของ container
              height: 100, // กำหนดขนาดของ container
              decoration: BoxDecoration(
                color: Colors.grey, // สีพื้นหลังของ container
                shape: BoxShape.circle, // ทำให้เป็นรูปวงกลม
              ),
              child: Center(
                child: Icon(
                  Icons
                      .person, // ไอคอนแสดงแทนรูปโปรไฟล์ (สามารถเปลี่ยนเป็นไอคอนอื่นได้)
                  size: 50, // ขนาดของไอคอน
                  color: Colors.white, // สีของไอคอน
                ),
              ),
            ),

            SizedBox(height: 16),
            Text(
              'Pubodee suwansung',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '31 Oct 2001',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),

            // User Info
            Text('Email: pubodee_058@smth.com'),
            SizedBox(height: 4),
            Text('Phone: 0971234433'),
            SizedBox(height: 16),
            Text('Faculty: IT'),
            SizedBox(height: 4),
            Text('Major: IT'),
            SizedBox(height: 4),
            Text('Student ID: 6712345678 (4th year)'),

            // Edit and Log Out Buttons
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Logic to Edit Profile
                    print('Edit Profile');
                  },
                  child: Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent, // Background color
                    minimumSize: Size(100, 50), // Button size
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logic to Log out
                    print('Log out');
                  },
                  child: Text('Log out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent, // Background color
                    minimumSize: Size(100, 50), // Button size
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}