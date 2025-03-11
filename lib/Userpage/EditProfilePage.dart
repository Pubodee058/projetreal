import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/Userpage/profileuserpage.dart';
import 'package:myproject/constant.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  // Controller สำหรับฟิลด์ข้อมูล
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  String? _selectedGrade; // เก็บค่า Grade ที่เลือก

  bool isLoading = true; // ใช้เช็คว่ากำลังโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // โหลดข้อมูลผู้ใช้เมื่อเปิดหน้า
  }

  /// 📌 ดึงข้อมูลของ User จาก Firestore
  Future<void> _fetchUserData() async {
    if (user == null) return;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();

    if (userDoc.exists) {
      setState(() {
        _firstNameController.text = userDoc['stu_firstname'];
        _lastNameController.text = userDoc['stu_lastname'];
        _phoneController.text = userDoc['stu_tel'];
        _facultyController.text = userDoc['stu_faculty'];
        _majorController.text = userDoc['stu_major'];
        _selectedGrade = userDoc['stu_grade'].toString();
        isLoading = false; // โหลดเสร็จแล้ว
      });
    }
  }

  /// 📌 บันทึกข้อมูลที่แก้ไขลง Firestore
Future<void> _saveProfile() async {
  if (user == null) return;

  // Get old name before updating
  DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
  String oldFirstName = userDoc['stu_firstname'];
  String oldLastName = userDoc['stu_lastname'];

  // Update the 'users' collection
  await _firestore.collection('users').doc(user!.uid).update({
    'stu_firstname': _firstNameController.text,
    'stu_lastname': _lastNameController.text,
    'stu_tel': _phoneController.text,
    'stu_faculty': _facultyController.text,
    'stu_major': _majorController.text,
    'stu_grade': int.parse(_selectedGrade!),
  });

  // ✅ Update related records in practice_users collection
  await _updatePracticeUsers(oldFirstName, oldLastName, _firstNameController.text, _lastNameController.text);

  // ✅ Update other tables if needed (example)
  await _updateOtherCollections(oldFirstName, oldLastName, _firstNameController.text, _lastNameController.text);

  /// 📌 Show Popup Confirmation & Redirect
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Success"),
      content: Text("Your profile has been updated successfully!"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Profileuserpage()),
            );
          },
          child: Text("OK"),
        ),
      ],
    ),
  );
}

Future<void> _updatePracticeUsers(
    String oldFirstName, String oldLastName, String newFirstName, String newLastName) async {
  QuerySnapshot query = await _firestore
      .collection('practice_users')
      .where('stu_firstname', isEqualTo: oldFirstName)
      .where('stu_lastname', isEqualTo: oldLastName)
      .get();

  for (var doc in query.docs) {
    await doc.reference.update({
      'stu_firstname': newFirstName,
      'stu_lastname': newLastName,
    });
  }
}

Future<void> _updateOtherCollections(
    String oldFirstName, String oldLastName, String newFirstName, String newLastName) async {
  List<String> collectionsToUpdate = ['some_other_table', 'another_table'];

  for (String collection in collectionsToUpdate) {
    QuerySnapshot query = await _firestore
        .collection(collection)
        .where('stu_firstname', isEqualTo: oldFirstName)
        .where('stu_lastname', isEqualTo: oldLastName)
        .get();

    for (var doc in query.docs) {
      await doc.reference.update({
        'stu_firstname': newFirstName,
        'stu_lastname': newLastName,
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile",style: TextStyle(color: Colors.white),),
        backgroundColor: red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // แสดงโหลดข้อมูล
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// 🔹 **First Name**
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: "First Name",
                        hintText: "Current: ${_firstNameController.text}",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),

                    /// 🔹 **Last Name**
                    TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        hintText: "Current: ${_lastNameController.text}",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),

                    /// 🔹 **Phone Number**
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        hintText: "Current: ${_phoneController.text}",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),

                    /// 🔹 **Faculty**
                    TextField(
                      controller: _facultyController,
                      decoration: InputDecoration(
                        labelText: "Faculty",
                        hintText: "Current: ${_facultyController.text}",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),

                    /// 🔹 **Major**
                    TextField(
                      controller: _majorController,
                      decoration: InputDecoration(
                        labelText: "Major",
                        hintText: "Current: ${_majorController.text}",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),

                    /// 🔹 **Grade (Dropdown)**
                    DropdownButtonFormField<String>(
                      value: _selectedGrade,
                      items: ["1", "2", "3", "4"].map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text("Grade $grade"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGrade = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Grade",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),

                    /// 🔹 **Save Button**
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text("Save",style: TextStyle(
                        color: Colors.white
                      ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
