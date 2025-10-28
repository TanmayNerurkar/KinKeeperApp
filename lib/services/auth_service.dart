import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'child',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create user document in Firestore
        UserModel userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          familyId: '',
          joinedAt: DateTime.now(),
          role: role,
        );

        await _db.collection('users').doc(user.uid).set(userModel.toMap());
        notifyListeners();
        return userModel;
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          notifyListeners();
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
        }
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get user data by UID
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // Join family
  Future<void> joinFamily(String userId, String familyId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'familyId': familyId,
      });
      notifyListeners();
    } catch (e) {
      print('Error joining family: $e');
      rethrow;
    }
  }

  // Leave family
  Future<void> leaveFamily(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'familyId': '',
      });
      notifyListeners();
    } catch (e) {
      print('Error leaving family: $e');
      rethrow;
    }
  }
}
