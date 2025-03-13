import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/constant.dart';

class EditPracticePage extends StatefulWidget {
  final String practiceId;

  EditPracticePage({required this.practiceId});

  @override
  _EditPracticePageState createState() => _EditPracticePageState();
}

class _EditPracticePageState extends State<EditPracticePage> {
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  final _budgetOtController = TextEditingController();
  final _budgetLateController = TextEditingController();

  DateTime? _practiceDate;
  String? _startTime;
  String? _endTime;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPracticeData();
  }

  /// 📌 ดึงข้อมูล `pratice` จาก Firestore ตาม `practiceId`
  Future<void> _fetchPracticeData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('pratice')
          .doc(widget.practiceId)
          .get();

      if (!doc.exists) {
        print("❌ Practice not found");
        Navigator.pop(context);
        return;
      }

      // ดึงข้อมูลจาก doc
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        _titleController.text = data['prt_title'] ?? '';
        _detailController.text = data['prt_detail'] ?? '';
        _budgetOtController.text =
            data['prt_budget_ot'] != null ? data['prt_budget_ot'].toString() : '';
        _budgetLateController.text = data['prt_budget_late'] != null
            ? data['prt_budget_late'].toString()
            : '';

        if (data['prt_date'] is Timestamp) {
          _practiceDate = (data['prt_date'] as Timestamp).toDate();
        }
        _startTime = data['prt_start_time'] ?? '';
        _endTime = data['prt_end_time'] ?? '';

        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching practice: $e");
      Navigator.pop(context);
    }
  }

  /// 📌 เมื่อกดบันทึก → อัปเดตข้อมูลใน `pratice`
Future<void> _updatePractice() async {
  try {
    await FirebaseFirestore.instance
        .collection('pratice')
        .doc(widget.practiceId)  // ชี้ไปที่เอกสารเดิม
        .update({
      'prt_title': _titleController.text,
      'prt_detail': _detailController.text,
      'prt_budget_ot': double.tryParse(_budgetOtController.text) ?? 0,
      'prt_budget_late': double.tryParse(_budgetLateController.text) ?? 0,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Practice updated successfully!")),
    );

    Navigator.pop(context); // ปิดหน้าหลังบันทึกสำเร็จ
  } catch (e) {
    print("❌ Error updating practice: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed to update practice.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Edit Practice"), backgroundColor: Colors.redAccent),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Practice",style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Practice on ${_titleController.text}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              /// 🔹 Title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Edit title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              /// 🔹 วันที่ → ล็อคไม่ให้แก้
              TextField(
                enabled: false, // ✅ ล็อคห้ามแก้
                decoration: InputDecoration(
                  labelText: "Set date",
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: _practiceDate != null
                      ? DateFormat('dd / MMM / yyyy').format(_practiceDate!)
                      : "No date",
                ),
              ),
              SizedBox(height: 16),

              /// 🔹 Start - End Time → ล็อคไม่ให้แก้
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false, // ❌ ล็อคไม่ให้แก้
                      decoration: InputDecoration(
                        labelText: "Start time",
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _startTime),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "End time",
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _endTime),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              /// 🔹 Detail
              TextField(
                controller: _detailController,
                decoration: InputDecoration(
                  labelText: "Detail",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              /// 🔹 Budget OT
              TextField(
                controller: _budgetOtController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Budget for on-time person",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              /// 🔹 Budget Late
              TextField(
                controller: _budgetLateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Budget for late person",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              /// 🔹 ปุ่มบันทึก
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updatePractice,
                  child: Text("Save",style: TextStyle(
                    color: Colors.white
                  ),),
                  style: ElevatedButton.styleFrom(backgroundColor: red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
