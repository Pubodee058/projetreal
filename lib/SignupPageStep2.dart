import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/main.dart';

class SignupPageStep2 extends StatefulWidget {
  final String password;
  final String email;

  SignupPageStep2({
    required this.password,
    required this.email,
  });

  @override
  _SignupPageStep2State createState() => _SignupPageStep2State();
}

class _SignupPageStep2State extends State<SignupPageStep2> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  DateTime? selectedBirthDate;
  int? selectedGrade; // ค่า Grade ที่เลือก
  bool isLoading = false;

  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedBirthDate = pickedDate;
        birthDateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}"; // ✅ ใช้รูปแบบ YYYY-MM-DD
      });

      print(
          "วันเกิดที่เลือก: ${birthDateController.text}"); // ✅ ตรวจสอบค่าที่อัปเดตใน Console
    }
  }

Future<void> _registerUser() async {
  List<String> missingFields = [];

  if (firstNameController.text.isEmpty) missingFields.add("ชื่อจริง");
  if (lastNameController.text.isEmpty) missingFields.add("นามสกุล");
  if (phoneNumberController.text.isEmpty) missingFields.add("เบอร์โทรศัพท์");
  if (selectedBirthDate == null) missingFields.add("วันเกิด");
  if (studentIdController.text.isEmpty) missingFields.add("รหัสนักศึกษา"); // ✅ เช็คว่าผู้ใช้กรอกหรือไม่
  if (facultyController.text.isEmpty) missingFields.add("คณะ");
  if (majorController.text.isEmpty) missingFields.add("สาขา");
  if (selectedGrade == null) missingFields.add("ระดับชั้น");

  if (missingFields.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("กรุณากรอกข้อมูลให้ครบ: ${missingFields.join(', ')}"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    // ✅ สมัครสมาชิก Firebase Authentication
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: widget.email,
      password: widget.password,
    );

    String firebaseUID = userCredential.user!.uid;
    String userID = studentIdController.text.trim(); // ✅ ใช้ค่าจากที่ผู้ใช้กรอก

    // ✅ บันทึกข้อมูลลง Firestore พร้อม `user_id`
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUID)
        .set({
      'firebase_uid': firebaseUID,
      'stu_id': userID, // ✅ ใช้ค่าที่ผู้ใช้กรอกในช่อง studentIdController
      'stu_email': widget.email,
      'stu_firstname': firstNameController.text,
      'stu_lastname': lastNameController.text,
      'stu_birthdate': selectedBirthDate!.toIso8601String(),
      'stu_tel': phoneNumberController.text,
      'stu_faculty': facultyController.text,
      'stu_major': majorController.text,
      'stu_grade': selectedGrade,
      'role': "user", // ✅ กำหนดค่า role เป็น "user"
      'createdAt': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')),
    );

    // ✅ พาผู้ใช้ไปหน้า Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up - Step 2'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                  labelText: 'ชื่อจริง', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                  labelText: 'นามสกุล', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: studentIdController,
              decoration: InputDecoration(
                  labelText: 'รหัสนักศึกษา', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: birthDateController,
              readOnly: true, // ✅ ป้องกันไม่ให้ผู้ใช้พิมพ์เอง
              decoration: InputDecoration(
                labelText: "วันเกิด",
                hintText:
                    "เลือกวันเกิด", // ✅ เพิ่มข้อความกำกับเมื่อยังไม่ได้เลือกวัน
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectBirthDate(context),
                ),
              ),
            ),
            TextField(
              controller: facultyController,
              decoration: InputDecoration(
                  labelText: 'คณะ', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: majorController,
              decoration: InputDecoration(
                  labelText: 'สาขา', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: "ระดับชั้น",
                border: OutlineInputBorder(),
              ),
              value: selectedGrade,
              items: [
                DropdownMenuItem(value: 1, child: Text("ปี 1")),
                DropdownMenuItem(value: 2, child: Text("ปี 2")),
                DropdownMenuItem(value: 3, child: Text("ปี 3")),
                DropdownMenuItem(value: 4, child: Text("ปี 4")),
                DropdownMenuItem(value: 5, child: Text("ปี 5")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGrade = value!;
                });
                print(
                    "ระดับชั้นที่เลือก: $selectedGrade"); // ✅ ตรวจสอบค่าใน console
              },
            ),
            isLoading
                ? CircularProgressIndicator() // แสดง Loading ขณะกำลังบันทึกข้อมูล
                : ElevatedButton(
                    onPressed: _registerUser, // เรียกใช้งานฟังก์ชันสมัครสมาชิก
                    child: Text("สมัครสมาชิก"),
                  ),
          ],
        ),
      ),
    );
  }
}
