import 'package:flutter/material.dart';
import '../widgets/study_option.dart';
import 'package:my_first_flutter_app/screens/ai_study_screen.dart';
import 'package:my_first_flutter_app/screens/solo_study_screen.dart';


class StudySessionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('STUDY SESSION')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AIStudyScreen()),
                  );
                },
                child: StudyOption(icon: Icons.computer, label: 'AI STUDY'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SoloStudyScreen()),
                  );
                },
                child: StudyOption(icon: Icons.self_improvement, label: 'SOLO STUDY'),
              ),
            ],
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('BACK'),
          )
        ],
      ),
    );
  }
}
