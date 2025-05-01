import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _addReminder(String reminder) async {
    if (reminder.isEmpty || _selectedDay == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final localDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    await FirebaseFirestore.instance
        .collection('schedule')
        .doc(user.uid)
        .collection('reminders')
        .add({
      'text': reminder,
      'date': Timestamp.fromDate(localDate),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _deleteReminder(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('schedule')
        .doc(user.uid)
        .collection('reminders')
        .doc(docId)
        .delete();
  }

  void _showAddReminderDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Study Reminder'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter your reminder...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              _addReminder(_controller.text.trim());
              Navigator.pop(context);
            },
            child: Text('ADD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Schedule')),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedDay == null ? null : _showAddReminderDialog,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: user == null || _selectedDay == null
                ? Center(child: Text('Please select a date and log in.'))
                : StreamBuilder<QuerySnapshot>(
              stream: () {
                final startOfDay = DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                );
                final endOfDay = DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                  23, 59, 59, 999,
                );

                return FirebaseFirestore.instance
                    .collection('schedule')
                    .doc(user.uid)
                    .collection('reminders')
                    .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                    .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
                    .orderBy('date')
                    .snapshots();
              }(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: \${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final reminders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return Dismissible(
                      key: Key(reminder.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteReminder(reminder.id),
                      child: ListTile(
                        title: Text(reminder['text']),
                        leading: Icon(Icons.schedule),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
