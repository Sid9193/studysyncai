import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();

  Future<void> _addTask() async {
    final task = _taskController.text.trim();
    if (task.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(user.uid)
          .collection('user_tasks')
          .add({
        'text': task,
        'done': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _taskController.clear();
    }
  }

  Future<void> _toggleDone(DocumentSnapshot task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final currentStatus = task['done'] as bool;
    await task.reference.update({'done': !currentStatus});
  }

  Future<void> _deleteTask(DocumentSnapshot task) async {
    await task.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'New Task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addTask(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: user == null
                  ? Center(child: Text("Please log in to see tasks."))
                  : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(user.uid)
                    .collection('user_tasks')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task['done'],
                          onChanged: (_) => _toggleDone(task),
                        ),
                        title: Text(
                          task['text'],
                          style: TextStyle(
                            decoration: task['done']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTask(task),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
