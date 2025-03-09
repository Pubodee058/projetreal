import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myproject/SignupPageStep2.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _goToNextPage() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอก Email และ Password')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ตรวจสอบว่า Email นี้มีอยู่แล้วใน Firestore หรือไม่
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('stu_email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ถ้า Email ซ้ำ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email นี้ถูกใช้งานแล้ว กรุณาใช้ Email อื่น')),
        );
      } else {
        // ถ้า Email ไม่ซ้ำ → ไปหน้า 2
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupPageStep2(email: email, password: password),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('สมัครสมาชิค',style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField(
            //   controller: usernameController,
            //   decoration: InputDecoration(
            //     labelText: 'Username',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: size.height * 0.015),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: size.height * 0.015),
            isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                  width: size.width * 0.85,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                      onPressed: _goToNextPage,
                      child: Text('Next',style: TextStyle(
                        color: Colors.white,fontSize: 16
                      ),),
                    ),
                ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _goToNextPage,
            //   child: Text('Next'),
            // ),
          ],
        ),
      ),
    );
  }
}