import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTaskPage extends StatefulWidget {
  final String familyId;
  AddTaskPage({required this.familyId});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _priority = 'Medium';
  String? _assignedTo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _descController, decoration: InputDecoration(labelText: 'Description')),
            DropdownButtonFormField<String>(
              value: _priority,
              items: ['High', 'Medium', 'Low'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _priority = val!),
              decoration: InputDecoration(labelText: 'Priority'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('tasks').add({
      'title': _titleController.text,
      'description': _descController.text,
      'priority': _priority,
      'assignedTo': _assignedTo ?? currentUser.uid,
      'assignedBy': currentUser.uid,
      'familyId': widget.familyId,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
  }
}
