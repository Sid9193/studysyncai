import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../widgets/menu_item.dart';
import '../screens/study_session_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import '../screens/schedule_screen.dart';
import 'package:my_first_flutter_app/screens/settings_screen.dart';
import '../screens/ai_study_screen.dart';
import '../screens/solo_study_screen.dart';
import 'package:my_first_flutter_app/screens/task_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  runApp(StudySyncAI());
}

class StudySyncAI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudySync AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome ${FirebaseAuth.instance.currentUser?.email ?? 'User'}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            padding: EdgeInsets.all(20),
            children: [
              MenuItem(icon: Icons.calendar_today, label: 'SCHEDULE', route: ScheduleScreen()),
              MenuItem(icon: Icons.timer, label: 'STUDY SESSION', route: StudySessionScreen()),
              MenuItem(icon: Icons.checklist, label: 'TASKS', route: TaskScreen()),
              MenuItem(icon: Icons.settings, label: 'SETTINGS', route: SettingsScreen()),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              'Version 0.1',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class SoloStudyScreen extends StatefulWidget {
  @override
  _SoloStudyScreenState createState() => _SoloStudyScreenState();
}

class _SoloStudyScreenState extends State<SoloStudyScreen> {
  final TextEditingController _studyController = TextEditingController(text: '25');
  final TextEditingController _breakController = TextEditingController(text: '5');

  int _studyMinutes = 25;
  int _breakMinutes = 5;
  Duration _timeLeft = Duration(minutes: 25);
  bool _isStudying = true;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _applyInput();
  }

  void _applyInput() {
    setState(() {
      _studyMinutes = int.tryParse(_studyController.text) ?? 25;
      _breakMinutes = int.tryParse(_breakController.text) ?? 5;
      _timeLeft = Duration(minutes: _studyMinutes);
      _isStudying = true;
      _isRunning = false;
    });
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    Future.doWhile(() async {
      if (!_isRunning) return false;

      if (_timeLeft.inSeconds <= 0) {
        setState(() {
          _isStudying = !_isStudying;
          _timeLeft = Duration(minutes: _isStudying ? _studyMinutes : _breakMinutes);
        });
      }

      await Future.delayed(Duration(seconds: 1));
      if (_isRunning) {
        setState(() {
          _timeLeft = _timeLeft - Duration(seconds: 1);
        });
      }
      return _isRunning;
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _applyInput();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Solo Study')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isStudying ? 'Study Time' : 'Break Time',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              _formatDuration(_timeLeft),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  child: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 40),
            TextField(
              controller: _studyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Study Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _applyInput(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _breakController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Break Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _applyInput(),
            ),
          ],
        ),
      ),
    );
  }
}



