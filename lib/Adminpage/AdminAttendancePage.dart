import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/constant.dart';

class AdminAttendancePage extends StatefulWidget {
  @override
  _AdminAttendancePageState createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> attendanceData = [];

  /// 📌 ฟังก์ชันเลือกวันที่
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDate ?? DateTime.now() : endDate ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  /// 📌 ดึงข้อมูลจาก Firestore ตามช่วงวันที่ที่เลือก
  Future<void> _fetchAttendanceData() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("กรุณาเลือกช่วงวันที่")));
      return;
    }

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('practice_users')
        .where('prt_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!))
        .where('prt_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate!))
        .orderBy('prt_date')
        .get();

    List<Map<String, dynamic>> fetchedData = query.docs.map((doc) {
      return {
        'stu_firstname': doc['stu_firstname'],
        'stu_lastname': doc['stu_lastname'],
        'prt_date': (doc['prt_date'] as Timestamp).toDate(),
        'status': doc['status'],
      };
    }).toList();

    setState(() {
      attendanceData = fetchedData;
    });
  }

  /// 📌 ฟังก์ชันแปลงวันที่เป็น String
  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Report',style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Filter Section (เลือกช่วงวันที่)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(startDate != null ? _formatDate(startDate!) : "Start Date"),
                    leading: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(endDate != null ? _formatDate(endDate!) : "End Date"),
                    leading: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
                ElevatedButton(
                  onPressed: _fetchAttendanceData,
                  child: Text("Filter",style: TextStyle(
                    color: Colors.white
                  ),),
                  style: ElevatedButton.styleFrom(backgroundColor: red),
                ),
              ],
            ),

            SizedBox(height: 20),

            /// 🔹 Table Header
            attendanceData.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 15,
                      columns: [
                        DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                        ..._generateDateColumns(), // ✅ สร้างคอลัมน์วันที่
                      ],
                      rows: _generateRows(), // ✅ สร้างแถวข้อมูล
                    ),
                  )
                : Center(child: Text("เลือกช่วงวันที่เพื่อดูข้อมูล")),
          ],
        ),
      ),
    );
  }

  /// 📌 สร้างคอลัมน์ของวันที่ (Header ของตาราง)
  List<DataColumn> _generateDateColumns() {
    Set uniqueDates = attendanceData.map((e) => e['prt_date']).toSet();
    return uniqueDates.map((date) {
      return DataColumn(label: Text(_formatDate(date), style: TextStyle(fontWeight: FontWeight.bold)));
    }).toList();
  }

  /// 📌 สร้างแถวของข้อมูล
  List<DataRow> _generateRows() {
    // ✅ กลุ่มข้อมูลตามชื่อผู้ใช้
    Map<String, Map<DateTime, String>> groupedData = {};

    for (var entry in attendanceData) {
      String name = "${entry['stu_firstname']} ${entry['stu_lastname']}";
      DateTime date = entry['prt_date'];
      String status = entry['status'];

      if (!groupedData.containsKey(name)) {
        groupedData[name] = {};
      }
      groupedData[name]![date] = status;
    }

    // ✅ สร้างแถวของตาราง
    return groupedData.entries.map((entry) {
      List<DataCell> cells = [
        DataCell(Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold))),
      ];

      Set uniqueDates = attendanceData.map((e) => e['prt_date']).toSet();

      for (var date in uniqueDates) {
        String status = entry.value[date] ?? "N/A";
        Color statusColor = Colors.grey;
        if (status == "on_time") statusColor = Colors.green;
        if (status == "late") statusColor = Colors.orange;
        if (status == "absent") statusColor = Colors.red;
        if (status == "leave") statusColor = Colors.blue;

        cells.add(
          DataCell(Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          )),
        );
      }

      return DataRow(cells: cells);
    }).toList();
  }
}
