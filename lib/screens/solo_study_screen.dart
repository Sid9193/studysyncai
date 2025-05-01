import 'package:flutter/material.dart';

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
