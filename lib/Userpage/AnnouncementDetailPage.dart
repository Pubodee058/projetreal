import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/constant.dart';

class AnnouncementUserDetailPage extends StatefulWidget {
  final String announcementId; // รับ ID ของ Announcement

  AnnouncementUserDetailPage({required this.announcementId});

  @override
  _AnnouncementUserDetailPageState createState() => _AnnouncementUserDetailPageState();
}

class _AnnouncementUserDetailPageState extends State<AnnouncementUserDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? annData;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncementData();
  }

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

      setState(() {
        annData = doc.data() as Map<String, dynamic>;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching announcement: $e");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Announcement Detail"),
          backgroundColor: red,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ เมื่อโหลดเสร็จแล้ว ประกาศข้อมูล
    DateTime annDate = (annData!['ann_date'] as Timestamp).toDate();
    String annTitle = annData!['ann_title'] ?? 'No Title';
    String annDetail = annData!['ann_detail'] ?? 'No Detail';
    String annStartTime = annData!['ann_start_time'] ?? '';
    String annEndTime = annData!['ann_end_time'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Announcement Detail"),
        backgroundColor: red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔹 Header (Title + Date + Time)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    annTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(annDate),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$annStartTime - $annEndTime",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            /// 🔹 Detail
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                annDetail,
                style: TextStyle(fontSize: 16),
              ),
            ),

            Spacer(),
            // 🔹 ไม่มีปุ่ม Join
          ],
        ),
      ),
    );
  }
}
