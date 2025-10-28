import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyModel {
  final String familyId;
  final String familyName;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;
  final String? description;

  FamilyModel({
    required this.familyId,
    required this.familyName,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    this.description,
  });

  factory FamilyModel.fromMap(Map<String, dynamic> map, String familyId) {
    return FamilyModel(
      familyId: familyId,
      familyName: map['familyName'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyName': familyName,
      'createdBy': createdBy,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
    };
  }

  FamilyModel copyWith({
    String? familyId,
    String? familyName,
    String? createdBy,
    List<String>? members,
    DateTime? createdAt,
    String? description,
  }) {
    return FamilyModel(
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  // Helper methods
  int get memberCount => members.length;
  bool isMember(String userId) => members.contains(userId);
  bool isCreator(String userId) => createdBy == userId;
}

