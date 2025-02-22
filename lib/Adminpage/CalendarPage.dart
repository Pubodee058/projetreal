import 'dart:convert';

import 'package:flutter/material.dart' ;
import 'package:intl/intl.dart';
import 'package:myproject/Adminpage/CalendarPage/EvendetailPage.dart';
import 'package:myproject/Adminpage/CalendarPage/EventPage.dart';
import 'package:myproject/Adminpage/CalendarPage/PracticeDetailPage.dart';
import 'package:myproject/Adminpage/CalendarPage/PracticePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  late TextEditingController _eventController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isFabExpanded = false;
  String _eventType = 'Event';

  @override
  void initState() {
    super.initState();
    // _eventController = TextEditingController();
    _selectedDate = DateTime.now();
    // _selectedTime = TimeOfDay(hour: 9, minute: 0);
    _events = {};
    _loadEvents();
  }

  _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEvents = prefs.getString('events');
    if (savedEvents != null) {
      Map<String, dynamic> data = jsonDecode(savedEvents);
      setState(() {
        _events = {};
        data.forEach((key, value) {
          try {
            DateTime date = DateTime.parse(key);
            List<Map<String, String>> eventList =
                List<Map<String, String>>.from(
              value.map((e) => Map<String, String>.from(e)),
            );
            _events[date] = eventList;
          } catch (e) {
            print('Error parsing date $key: $e');
          }
        });
      });
    }
  }

  // _saveEvent(Map<String, dynamic> eventData) async {
  //   // ถ้า eventData เป็น Map<String, String> แล้วแปลงเป็น Map<String, dynamic>
  //   Map<String, dynamic> formattedEventData = {
  //     'title': eventData['title'] ?? '', // เก็บ 'title' ที่ส่งมา
  //     'description': eventData['description'] ?? '',
  //     'time': eventData['time'] ?? '',
  //     'type': eventData['type'] ?? '',
  //     'date': eventData['date'] ?? DateTime.now(), // เพิ่ม 'date' ด้วย
  //   };

  //   setState(() {
  //     if (!_events.containsKey(_selectedDate)) {
  //       _events[_selectedDate] = [];
  //     }
  //     _events[_selectedDate]!
  //         .add(formattedEventData); // เพิ่มข้อมูลที่ถูกแปลงแล้ว
  //   });

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   Map<String, dynamic> jsonEvents = _events.map((key, value) {
  //     return MapEntry(key.toIso8601String(), value);
  //   });

  //   prefs.setString('events', jsonEncode(jsonEvents));
  // }

  // _saveEvent(Map<String, dynamic> eventData) async {
  //   // แปลง eventData เป็น Map<String, String>
  //   Map<String, String> formattedEventData = {
  //     'title': eventData['title'] ?? '', // เก็บ 'title' ที่ส่งมา
  //     'description': eventData['description'] ?? '',
  //     'time': eventData['time'] ?? '',
  //     'type': eventData['type'] ?? '',
  //     'date': eventData['date'].toIso8601String(), // แปลง date ให้เป็น String
  //   };

  //   setState(() {
  //     if (!_events.containsKey(_selectedDate)) {
  //       _events[_selectedDate] = [];
  //     }
  //     _events[_selectedDate]!
  //         .add(formattedEventData); // เพิ่มข้อมูลที่ถูกแปลงแล้ว
  //   });

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   Map<String, dynamic> jsonEvents = _events.map((key, value) {
  //     return MapEntry(key.toIso8601String(), value);
  //   });

  //   prefs.setString('events', jsonEncode(jsonEvents));
  // }
  _saveEvent(Map<String, dynamic> eventData) async {
  // แปลง eventData เป็น Map<String, String>
  Map<String, String> formattedEventData = {
    'title': eventData['title'] ?? '', // เก็บ 'title' ที่ส่งมา
    'description': eventData['description'] ?? '',
    'time': eventData['time'] ?? '',
    'type': eventData['type'] ?? '',
    'date': eventData['date'].toIso8601String(), // แปลง date ให้เป็น String
  };

  setState(() {
    if (!_events.containsKey(_selectedDate)) {
      _events[_selectedDate] = [];
    }
    _events[_selectedDate]!.add(formattedEventData); // เพิ่มข้อมูลที่ถูกแปลงแล้ว
  });

  // เก็บข้อมูลใน SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> eventList = _events[_selectedDate]!.map((e) => jsonEncode(e)).toList();
  prefs.setStringList('events', eventList);  // เก็บเป็น List ของ JSON string
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildAllEventsSection(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // FAB หลักที่แสดงปุ่มย่อย
  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          _buildSubFab(
            label: 'Announcement',
            icon: Icons.announcement,
            color: Colors.redAccent,
            onTap: () {
              setState(() => _isFabExpanded = false);
              // ส่งวันที่ที่เลือกไปยังหน้า Event
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventPage(selectedDate: _selectedDate),
                ),
              ).then((eventData) {
                if (eventData != null) {
                  _saveEvent(eventData); // เพิ่มข้อมูลใหม่
                }
              });
            },
          ),
          SizedBox(height: 10),
          _buildSubFab(
            label: 'Practice',
            icon: Icons.access_time,
            color: Colors.deepOrangeAccent,
            onTap: () {
              setState(() => _isFabExpanded = false);
              // ส่งวันที่ที่เลือกไปยังหน้า Practice
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PracticePage(selectedDate: _selectedDate),
                ),
              ).then((eventData) {
                if (eventData != null) {
                  _saveEvent(eventData); // เพิ่มข้อมูลใหม่
                }
              });
            },
          ),
          SizedBox(height: 10),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() => _isFabExpanded = !_isFabExpanded);
          },
          backgroundColor: Colors.redAccent,
          child: Icon(_isFabExpanded ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  Widget _buildSubFab({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FloatingActionButton.extended(
      heroTag: label,
      onPressed: onTap,
      label: Text(label),
      icon: Icon(icon),
      backgroundColor: color,
    );
  }

  Widget _buildAllEventsSection() {
    List<Map<String, dynamic>> allEvents = [];
    _events.forEach((date, events) {
      allEvents.addAll(events.map((e) => {
            'date': date,
            'time': e['time'] ?? '',
            'description': e['description'] ?? '',
            'type': e['type'] ?? '',
          }));
    });

    List<Map<String, dynamic>> eventList =
        allEvents.where((e) => e['type'] == 'Event').toList();
    List<Map<String, dynamic>> practiceList =
        allEvents.where((e) => e['type'] == 'Practice').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eventList.isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Events/Announcement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          ...eventList.map((event) => _buildEventCard(event)),
        ],
        if (practiceList.isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Practice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent,
              ),
            ),
          ),
          ...practiceList.map((event) => _buildEventCard(event)),
        ],
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          event['type'] == 'Event' ? Icons.announcement : Icons.access_time,
          color: event['type'] == 'Event'
              ? Colors.redAccent
              : Colors.deepOrangeAccent,
        ),
        title: Text(event['title'] ?? 'No Title'),
        subtitle: Text(
          '${DateFormat('dd MMM yy').format(event['date'] is DateTime ? event['date'] : DateTime.parse(event['date'] ?? DateTime.now().toIso8601String()))} ${event['time']}',
        ),
        onTap: () {
          // เมื่อคลิกที่การ์ด ให้แสดงรายละเอียดของกิจกรรม
          Map<String, String> eventData = {
            'title': event['title'] ?? 'No Title',
            'description': event['description'] ?? '',
            'time': event['time'] ?? '',
            'type': event['type'] ?? '',
            'date': event['date'] is DateTime
                ? event['date'].toIso8601String()
                : event['date'] ?? '', // แปลง DateTime เป็น String
          };

          if (event['type'] == 'Practice') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeDetailPage(
                  event: eventData, // ส่งข้อมูลที่เป็น Map<String, String>
                  attendees: [
                    'John',
                    'Jane',
                    'Doe'
                  ], // ส่งรายชื่อผู้เข้าร่วมกิจกรรม
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(
                  event: eventData, // ส่งข้อมูลที่เป็น Map<String, String>
                ),
              ),
            );
          }
        },
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}