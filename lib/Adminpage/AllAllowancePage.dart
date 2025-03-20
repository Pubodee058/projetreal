import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myproject/constant.dart';

class AllAllowancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Allowance report',style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No users found."));
          }

          // 🔹 สร้าง DataTable
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // เผื่ออนาคตมีคอลัมน์เยอะ
            child: DataTable(
              columnSpacing: 30,
              columns: [
                DataColumn(label: Text("รหัสนักศึกษา")),
                DataColumn(label: Text("ชื่อ - สกุล")),
                DataColumn(label: Text("เบี้ยเลี้ยง")),
              ],
              rows: docs.map((doc) {
                // ดึง field ที่เราสนใจจาก Firestore
                String userId = doc['user_id'] ?? '';
                String firstname = doc['stu_firstname'] ?? '';
                String lastname = doc['stu_lastname'] ?? '';
                double allowance = (doc['allowance'] ?? 0).toDouble();

                return DataRow(
                  cells: [
                    DataCell(Text(userId)),
                    DataCell(Text("$firstname $lastname")),
                    DataCell(Text(allowance.toString())),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
