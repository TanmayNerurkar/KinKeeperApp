import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import 'login_page.dart';
import 'task_page.dart';
import 'family_page.dart';
import 'profile_page.dart';
import 'create_family_page.dart';
import 'join_family_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      if (mounted) {
        setState(() => _currentUser = userData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If user doesn't have a family, show appropriate page based on role
    if (_currentUser!.familyId.isEmpty) {
      if (_currentUser!.role == 'parent') {
        return const CreateFamilyPage();
      } else {
        return const JoinFamilyPage();
      }
    }

    final List<Widget> pages = [
      TaskPage(familyId: _currentUser!.familyId),
      FamilyPage(familyId: _currentUser!.familyId),
      ProfilePage(user: _currentUser!),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Family',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 && _currentUser!.role == 'parent'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(familyId: _currentUser!.familyId),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AddTaskPage extends StatefulWidget {
  final String familyId;

  const AddTaskPage({Key? key, required this.familyId}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Medium';
  String? _assignedTo;
  List<UserModel> _familyMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final firestoreService = FirestoreService();
      final members = await firestoreService.getFamilyMembers(widget.familyId).first;
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // Filter out the current user from the list
      final filteredMembers = members.where((member) => member.uid != currentUser?.uid).toList();
      
      setState(() {
        _familyMembers = filteredMembers;
      });
    } catch (e) {
      print('Error loading family members: $e');
      setState(() {
        _familyMembers = [];
      });
    }
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = FirestoreService();
      final currentUser = FirebaseAuth.instance.currentUser!;
      
      final task = TaskModel(
        taskId: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        assignedTo: _assignedTo!,
        assignedBy: currentUser.uid,
        familyId: widget.familyId,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.createTask(task);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Priority Dropdown
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (value) {
                  setState(() => _priority = value!);
                },
              ),
              const SizedBox(height: 16),
              
              // Assign To Dropdown
              DropdownButtonFormField<String>(
                value: _assignedTo,
                decoration: const InputDecoration(
                  labelText: 'Assign To',
                  border: OutlineInputBorder(),
                ),
                items: _familyMembers.map((member) {
                  return DropdownMenuItem(
                    value: member.uid,
                    child: Text(member.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _assignedTo = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a family member';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Add Task Button
              ElevatedButton(
                onPressed: _isLoading ? null : _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

