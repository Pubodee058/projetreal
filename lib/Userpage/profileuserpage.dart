import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/main.dart';

class Profileuserpage extends StatefulWidget {
  @override
  _ProfileuserpageState createState() => _ProfileuserpageState();
}

class _ProfileuserpageState extends State<Profileuserpage> {
  String firstName = "";
  String lastName = "";
  String birthDate = "";
  String email = "";
  String phone = "";
  String faculty = "";
  String major = "";
  String studentId = "";
  int studentGrade = 1;
  bool isLoading = true; // ใช้เช็คว่าข้อมูลโหลดเสร็จหรือยัง

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ดึงข้อมูลจาก Firestore เมื่อหน้าโหลด
  }

  Future<void> _fetchUserData() async {
    try {
      User? user =
          FirebaseAuth.instance.currentUser; // ดึงข้อมูลผู้ใช้ที่ล็อกอิน
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            firstName = userDoc['stu_firstname'];
            lastName = userDoc['stu_lastname'];
            birthDate = userDoc['stu_birthdate'];
            email = userDoc['stu_email'];
            phone = userDoc['stu_tel'];
            faculty = userDoc['stu_faculty'];
            major = userDoc['stu_major'];
            studentId = userDoc['user_id']; // ✅ ดึงค่าจาก Document ID แทน
            studentGrade = userDoc['stu_grade'];
            isLoading = false; // โหลดข้อมูลเสร็จ
          });
        }
      }
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // แสดง Loading ขณะดึงข้อมูล
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture and Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '$firstName $lastName', // ✅ แสดงชื่อจริงและนามสกุล
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          birthDate, // ✅ แสดงวันเกิด
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // User Info
                  Text('Email: $email'), // ✅ แสดงอีเมล
                  SizedBox(height: 4),
                  Text('Phone: $phone'), // ✅ แสดงเบอร์โทร
                  SizedBox(height: 16),
                  Text('Faculty: $faculty'), // ✅ แสดงคณะ
                  SizedBox(height: 4),
                  Text('Major: $major'), // ✅ แสดงสาขา
                  SizedBox(height: 4),
                  Text(
                      'Student ID: $studentId (ปี $studentGrade)'), // ✅ แสดงรหัสนักศึกษา + ปี

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
                          backgroundColor: Colors.orangeAccent,
                          minimumSize: Size(100, 50),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .signOut(); // ✅ ออกจากระบบ Firebase

                            // ✅ นำทางไปยังหน้า Login และล้าง Stack ทั้งหมด
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (route) => false, // ❌ ล้างทุกหน้าออกจาก Stack
                            );
                          } catch (e) {
                            print("เกิดข้อผิดพลาดขณะออกจากระบบ: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "ออกจากระบบไม่สำเร็จ! กรุณาลองใหม่")),
                            );
                          }
                        },
                        child: Text('Log out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(100, 50),
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
