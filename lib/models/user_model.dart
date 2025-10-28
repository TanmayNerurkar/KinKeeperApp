import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String familyId;
  final String profilePic;
  final DateTime joinedAt;
  final String role; // 'parent' or 'child'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.familyId,
    this.profilePic = '',
    required this.joinedAt,
    this.role = 'child',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      familyId: map['familyId'] ?? '',
      profilePic: map['profilePic'] ?? '',
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
      role: map['role'] ?? 'child',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'familyId': familyId,
      'profilePic': profilePic,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'role': role,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? familyId,
    String? profilePic,
    DateTime? joinedAt,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      familyId: familyId ?? this.familyId,
      profilePic: profilePic ?? this.profilePic,
      joinedAt: joinedAt ?? this.joinedAt,
      role: role ?? this.role,
    );
  }
}
