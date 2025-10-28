import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/family_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Task operations
  Future<String> createTask(TaskModel task) async {
    try {
      DocumentReference docRef = await _db.collection('tasks').add(task.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Stream<List<TaskModel>> getTasksByFamily(String familyId) {
    return _db
        .collection('tasks')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tasks;
        });
  }

  Stream<List<TaskModel>> getTasksByUser(String userId) {
    return _db
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tasks;
        });
  }

  Stream<List<TaskModel>> getTasksByStatus(String familyId, String status) {
    return _db
        .collection('tasks')
        .where('familyId', isEqualTo: familyId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tasks;
        });
  }

  // Family operations
  Future<String> createFamily(FamilyModel family) async {
    try {
      DocumentReference docRef = await _db.collection('families').add(family.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating family: $e');
      rethrow;
    }
  }

  Future<void> updateFamily(String familyId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('families').doc(familyId).update(updates);
    } catch (e) {
      print('Error updating family: $e');
      rethrow;
    }
  }

  Future<FamilyModel?> getFamily(String familyId) async {
    try {
      DocumentSnapshot doc = await _db.collection('families').doc(familyId).get();
      if (doc.exists) {
        return FamilyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting family: $e');
      return null;
    }
  }

  Future<void> addMemberToFamily(String familyId, String userId) async {
    try {
      await _db.collection('families').doc(familyId).update({
        'members': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print('Error adding member to family: $e');
      rethrow;
    }
  }

  Future<void> removeMemberFromFamily(String familyId, String userId) async {
    try {
      await _db.collection('families').doc(familyId).update({
        'members': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print('Error removing member from family: $e');
      rethrow;
    }
  }

  // User operations
  Stream<List<UserModel>> getFamilyMembers(String familyId) {
    return _db
        .collection('users')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Statistics
  Future<Map<String, int>> getTaskStats(String userId) async {
    try {
      QuerySnapshot pendingTasks = await _db
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .where('status', isEqualTo: 'Pending')
          .get();

      QuerySnapshot inProgressTasks = await _db
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .where('status', isEqualTo: 'In Progress')
          .get();

      QuerySnapshot completedTasks = await _db
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .where('status', isEqualTo: 'Completed')
          .get();

      return {
        'pending': pendingTasks.docs.length,
        'inProgress': inProgressTasks.docs.length,
        'completed': completedTasks.docs.length,
      };
    } catch (e) {
      print('Error getting task stats: $e');
      return {'pending': 0, 'inProgress': 0, 'completed': 0};
    }
  }

  // Search tasks
  Stream<List<TaskModel>> searchTasks(String familyId, String query) {
    return _db
        .collection('tasks')
        .where('familyId', isEqualTo: familyId)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

