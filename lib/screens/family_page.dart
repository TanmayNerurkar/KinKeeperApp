import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'create_family_page.dart';

class FamilyPage extends StatefulWidget {
  final String familyId;

  const FamilyPage({Key? key, required this.familyId}) : super(key: key);

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder(
            stream: _firestoreService.getFamilyMembers(widget.familyId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final members = snapshot.data!;
                final currentUser = FirebaseAuth.instance.currentUser;
                final currentUserData = members.firstWhere(
                  (member) => member.uid == currentUser?.uid,
                  orElse: () => UserModel(
                    uid: '',
                    name: '',
                    email: '',
                    familyId: '',
                    joinedAt: DateTime.now(),
                    role: 'child',
                  ),
                );
                
                // Only show add member button for parents
                if (currentUserData.role == 'parent') {
                  return IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () {
                      _showJoinFamilyDialog();
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _firestoreService.getFamilyMembers(widget.familyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading family members',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.family_restroom,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No family members yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add family members to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showJoinFamilyDialog();
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _buildMemberCard(member);
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder(
        stream: _firestoreService.getFamilyMembers(widget.familyId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final members = snapshot.data!;
            final currentUser = FirebaseAuth.instance.currentUser;
            final currentUserData = members.firstWhere(
              (member) => member.uid == currentUser?.uid,
              orElse: () => UserModel(
                uid: '',
                name: '',
                email: '',
                familyId: '',
                joinedAt: DateTime.now(),
                role: 'child',
              ),
            );
            
            // Only show add member button for parents
            if (currentUserData.role == 'parent') {
              return FloatingActionButton.extended(
                onPressed: () {
                  _showJoinFamilyDialog();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add Member'),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMemberCard(UserModel member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildRoleChip(member.role),
                const SizedBox(width: 8),
                Text(
                  'Joined ${_formatDate(member.joinedAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: member.role == 'parent'
            ? Icon(
                Icons.star,
                color: Colors.amber[600],
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    final isParent = role == 'parent';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isParent ? Colors.amber.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isParent ? Colors.amber : Colors.blue,
        ),
      ),
      child: Text(
        isParent ? 'Parent' : 'Member',
        style: TextStyle(
          color: isParent ? Colors.amber[800] : Colors.blue[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showJoinFamilyDialog() {
    final familyIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the Family ID to join an existing family:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: familyIdController,
              decoration: const InputDecoration(
                labelText: 'Family ID',
                hintText: 'Enter family ID here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _joinFamily(familyIdController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinFamily(String familyId) async {
    if (familyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Family ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        await authService.joinFamily(currentUser.uid, familyId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully joined family!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining family: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

