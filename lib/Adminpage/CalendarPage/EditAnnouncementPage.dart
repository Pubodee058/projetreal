import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditAnnouncementPage extends StatefulWidget {
  final String announcementId;

  EditAnnouncementPage({required this.announcementId});

  @override
  _EditAnnouncementPageState createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  DateTime? _annDate;
  String? _annStartTime;
  String? _annEndTime;

  bool _isLoading = true; // ใช้ตรวจสอบการโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    _fetchAnnouncementData();
  }

  /// 📌 ดึงข้อมูล Announcement
  Future<void> _fetchAnnouncementData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Announcement')
          .doc(widget.announcementId)
          .get();

      if (!doc.exists) {
        print("❌ Announcement not found");
        Navigator.pop(context);
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        _titleController.text = data['ann_title'] ?? '';
        _detailController.text = data['ann_detail'] ?? '';

        if (data['ann_date'] is Timestamp) {
          _annDate = (data['ann_date'] as Timestamp).toDate();
        }
        _annStartTime = data['ann_start_time'] ?? '';
        _annEndTime = data['ann_end_time'] ?? '';

        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching announcement: $e");
      Navigator.pop(context);
    }
  }

  /// 📌 แสดง Dialog ยืนยันว่าต้องการแก้ไขหรือไม่
  void _confirmUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Update'),
        content: Text('คุณต้องการเปลี่ยนแปลงประกาศนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('ตกลง', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(context);  // ปิด dialog
              _updateAnnouncement();   // เรียกฟังก์ชันอัปเดต
            },
          ),
        ],
      ),
    );
  }

  /// 📌 ฟังก์ชันอัปเดตเอกสารใน Firestore
  Future<void> _updateAnnouncement() async {
    try {
      await FirebaseFirestore.instance
          .collection('Announcement')
          .doc(widget.announcementId)
          .update({
        'ann_title': _titleController.text.trim(),
        'ann_detail': _detailController.text.trim(),
      });

      // 🔹 อัปเดตสำเร็จ → แจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ประกาศได้รับการอัปเดตเรียบร้อย!")),
      );

      // 🔹 กลับไปหน้าก่อนหน้านี้
      Navigator.pop(context);
    } catch (e) {
      print("❌ Error updating announcement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ไม่สามารถอัปเดตประกาศได้: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Edit Announcement"),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Announcement"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Announcement on ${_titleController.text}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              /// 🔹 **Title** (แก้ไขได้)
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Announcement Title",
                  hintText: "หัวข้อเดิม",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              /// 🔹 **Date** (ล็อก, ไม่ให้แก้)
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: _annDate != null
                      ? DateFormat('dd / MM / yyyy').format(_annDate!)
                      : "No Date",
                ),
              ),
              SizedBox(height: 16),

              /// 🔹 **Start - End Time** (ล็อก, ไม่ให้แก้)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Start Time",
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _annStartTime),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "End Time",
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _annEndTime),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              /// 🔹 **Detail** (แก้ไขได้)
              TextField(
                controller: _detailController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Detail",
                  hintText: "รายละเอียดเดิม",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              /// 🔹 **ปุ่ม Save** → เปิด Dialog ยืนยัน
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmUpdateDialog,
                  child: Text("Save"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
