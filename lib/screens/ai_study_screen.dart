import 'package:flutter/material.dart';

class AIStudyScreen extends StatefulWidget {
  @override
  _AIStudyScreenState createState() => _AIStudyScreenState();
}

class _AIStudyScreenState extends State<AIStudyScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _generatedPrompt = '';
  List<String> _studyPlan = [];

  void _generatePromptAndPlan() {
    String topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _generatedPrompt = 'Explain how "$topic" works in programming with an example.';
      _studyPlan = [
        'Session 1: 25 minutes focused on "$topic" concepts',
        'Break: 5 minutes',
        'Session 2: 25 minutes applying "$topic" through examples',
        'Break: 5 minutes',
        'Session 3: 25 minutes review and self-quiz on "$topic"',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Study')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  labelText: 'Enter a programming topic',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generatePromptAndPlan,
                child: Text('Generate Study Plan'),
              ),
              SizedBox(height: 30),
              if (_generatedPrompt.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Prompt:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _generatedPrompt,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Suggested Study Sessions:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ..._studyPlan.map((step) => ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text(step),
                    )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
