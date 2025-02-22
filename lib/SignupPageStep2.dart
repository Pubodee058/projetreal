import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

    if (pickedDate != null && pickedDate != selectedBirthDate) {
      setState(() {
        selectedBirthDate = pickedDate;
      });
    }
  }

  Future<void> _registerUser() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        birthDateController.text.isEmpty ||
        studentIdController.text.isEmpty ||
        facultyController.text.isEmpty ||
        majorController.text.isEmpty ||
        yearController.text.isEmpty) {
      // ✅ ลบ , ออกแล้ว
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // สมัครสมาชิก Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      String firebaseUID = userCredential.user!.uid;

      // บันทึกข้อมูลลง Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUID)
          .set({
        'firebase_uid': firebaseUID,
        'stu_email': widget.email,
        'stu_firstname': firstNameController.text,
        'stu_birthdate': DateTime.parse(birthDateController.text),
        'stu_tel': phoneNumberController.text,
        'stu_faculty': facultyController.text,
        'stu_major': majorController.text,
        'stu_grade': int.tryParse(yearController.text) ?? 0,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')),
      );

      Navigator.popUntil(context, (route) => route.isFirst); // กลับไปหน้าแรก
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
            Row(
              children: [
                Text(
                  selectedBirthDate == null
                      ? "กรุณาเลือกวันเกิด"
                      : "วันเกิด: ${selectedBirthDate!.toLocal()}"
                          .split(' ')[0],
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () => _selectBirthDate(context),
                  child: Text("เลือกวันเกิด"),
                ),
              ],
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
