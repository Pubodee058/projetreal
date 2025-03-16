import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Adminpage/CalendarPage/EditAnnouncementPage.dart';

class AnnouncementDetailPage extends StatefulWidget {
  final String announcementId; // รับ ID ของ Announcement

  AnnouncementDetailPage({required this.announcementId});

  @override
  _AnnouncementDetailPageState createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Announcement Detail"),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Announcement')
            .doc(widget.announcementId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No Announcement Found"));
          }

          var annData = snapshot.data!;
          DateTime annDate = (annData['ann_date'] as Timestamp).toDate();
          String annTitle = annData['ann_title'] ?? 'No Title';
          String annDetail = annData['ann_detail'] ?? 'No Detail';
          String annStartTime = annData['ann_start_time'] ?? '';
          String annEndTime = annData['ann_end_time'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// 🔹 **Title & Date & Time & Edit Icon**
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            annTitle,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(annDate),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "$annStartTime - $annEndTime",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 ปุ่ม Edit (Icon ดินสอ)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.brown),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAnnouncementPage(
                              announcementId:
                                  annData.id, // ใช้ doc.id จาก Firestore
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16),

                /// 🔹 **Detail**
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

                /// 🔹 **Delete Button**
                SizedBox(
                  width: double.infinity,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteDialog(annData),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔹 **ยืนยันการลบ**
  void _confirmDeleteDialog(DocumentSnapshot annData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Confirm', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              _deleteAnnouncement(annData.id);
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 **ฟังก์ชันลบ Announcement**
  void _deleteAnnouncement(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Announcement')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Announcement deleted successfully!")),
      );

      Navigator.pop(context); // กลับไปหน้าที่แล้ว
    } catch (e) {
      print("❌ Error deleting announcement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to delete announcement.")),
      );
    }
  }
}
