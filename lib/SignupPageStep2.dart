import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/constant.dart';
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
  if (studentIdController.text.isEmpty) missingFields.add("รหัสนักศึกษา"); 
  if (facultyController.text.isEmpty) missingFields.add("คณะ");
  if (majorController.text.isEmpty) missingFields.add("สาขา");
  if (selectedGrade == null) missingFields.add("ระดับชั้น");

  if (missingFields.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please fill in all information: ${missingFields.join(', ')}"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    String userID = studentIdController.text.trim();

    // 🟢 (1) ตรวจสอบว่า user_id นี้ซ้ำหรือไม่ใน Firestore
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: userID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // ถ้า user_id ซ้ำ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duplicate student ID number. Please change it.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // 🟢 (2) ถ้า user_id ไม่ซ้ำ → สร้างบัญชีใน Firebase Auth
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: widget.email,
      password: widget.password,
    );

    String firebaseUID = userCredential.user!.uid;

    // 🟢 (3) บันทึกข้อมูลลง Firestore ใน 'users'
    await FirebaseFirestore.instance.collection('users').doc(firebaseUID).set({
      'firebase_uid': firebaseUID,
      'user_id': userID, 
      'stu_email': widget.email,
      'stu_firstname': firstNameController.text,
      'stu_lastname': lastNameController.text,
      'stu_birthdate': selectedBirthDate!.toIso8601String(),
      'stu_tel': phoneNumberController.text,
      'stu_faculty': facultyController.text,
      'stu_major': majorController.text,
      'stu_grade': selectedGrade,
      'status': "",
      'role': "user",
      'allowance': 0, 
      'createdAt': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully registered!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
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
        backgroundColor: red,
        title: Text('Sign Up Information ',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                  labelText: 'Firstname', border: OutlineInputBorder()),
            ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                  labelText: 'Lastname', border: OutlineInputBorder()),
            ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                  labelText: 'Telephonenumber', border: OutlineInputBorder()),
            ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: studentIdController,
              decoration: InputDecoration(
                  labelText: 'StudentID', border: OutlineInputBorder()),
            ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: birthDateController,
              readOnly: true, // ✅ ป้องกันไม่ให้ผู้ใช้พิมพ์เอง
              decoration: InputDecoration(
                labelText: "Birthday",
                hintText:
                    "Please select your Birthday", // ✅ เพิ่มข้อความกำกับเมื่อยังไม่ได้เลือกวัน
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectBirthDate(context),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: facultyController,
              decoration: InputDecoration(
                  labelText: 'Faculty', border: OutlineInputBorder()),
            ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: majorController,
              decoration: InputDecoration(
                  labelText: 'Major', border: OutlineInputBorder()),
            ),
            SizedBox(height: size.height * 0.01),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: "Grade",
                border: OutlineInputBorder(),
              ),
              value: selectedGrade,
              items: const [
                DropdownMenuItem(value: 1, child: Text("1")),
                DropdownMenuItem(value: 2, child: Text("2")),
                DropdownMenuItem(value: 3, child: Text("3")),
                DropdownMenuItem(value: 4, child: Text("4")),
                DropdownMenuItem(value: 5, child: Text("5")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGrade = value!;
                });
                print(
                    "ระดับชั้นที่เลือก: $selectedGrade"); // ✅ ตรวจสอบค่าใน console
              },
            ),
            SizedBox(height: size.height * 0.01),
            isLoading
                ? CircularProgressIndicator() // แสดง Loading ขณะกำลังบันทึกข้อมูล
                : SizedBox(
                  width: size.width * 0.85,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red
                      ),
                      onPressed: _registerUser, // เรียกใช้งานฟังก์ชันสมัครสมาชิก
                      child: Text("Register",style: TextStyle(
                        color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold
                      ),),
                    ),
                ),
          ],
        ),
      ),
    );
  }
}
