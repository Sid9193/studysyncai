import 'package:flutter/material.dart';

class StudyOption extends StatelessWidget {
  final IconData icon;
  final String label;

  StudyOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 60),
        SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
