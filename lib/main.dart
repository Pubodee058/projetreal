import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myproject/Adminpage/Adminpage.dart';
import 'package:myproject/Userpage/Mainuserpage.dart';
import 'package:myproject/constant.dart';
import 'package:myproject/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // ✅ ต้องมีบรรทัดนี้
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Example',
      home: LoginPage(),
    );
  }
}
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

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
    // ✅ เช็คกรณีเป็น Admin (Fix ค่าไว้)
    if (email == "admin" && password == "123456") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
      return;
    }

    // ✅ ถ้าไม่ใช่ Admin → เช็ค Firebase Authentication
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    // ✅ ดึงข้อมูลผู้ใช้จาก Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      String userRole = userData['role'] ?? 'user'; // ถ้าไม่มี field 'role' ให้เป็น user

      // ✅ ถ้าเป็น User → ไปหน้า User Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Mainuserpage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้ในระบบ')),
      );
    }

  } on FirebaseAuthException catch (e) {
    // ⬅️ แยกส่วน catch ที่เป็น FirebaseAuthException
    if (e.code == 'user-not-found') {
      // ไม่มีบัญชีในระบบ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No account find try later')),
      );
    } else if (e.code == 'wrong-password') {
      // รหัสผ่านผิด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wrong-password try later')),
      );
    } else {
      // กรณีอื่น ๆ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not found try another Email or password')),
      );
    }
  } catch (e) {
    // ⬅️ กรณีเป็น Error ชนิดอื่นที่ไม่ใช่ FirebaseAuthException
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
      // appBar: AppBar(
      //   title: const Text('Login'),
      //   backgroundColor: Colors.redAccent,
      // ),
      body: Padding(
        padding: EdgeInsets.all(size.height * 0.01),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: size.height * 0.05),
              child: Image.asset(
                "assets/images/skrulogo.png"
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                  width: size.width * 0.99,
                  height: size.height * 0.05,
                  child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white
                      ),
                      child: Text('Login',style: TextStyle(fontSize: 18),),
                    ),
                ),
            SizedBox(height: size.height * 0.01),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: SizedBox(
                width: size.width * 0.3,
                height: size.height * 0.04,
                child: const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // decoration: TextDecoration.underline,
                      // decorationColor: Colors.white,
                      // decorationThickness: 2,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
