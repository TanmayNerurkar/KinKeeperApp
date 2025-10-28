import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final String priority; // 'High', 'Medium', 'Low'
  final String assignedTo;
  final String assignedBy;
  final String familyId;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes; // Optional notes from assignee

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.priority,
    required this.assignedTo,
    required this.assignedBy,
    required this.familyId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String taskId) {
    return TaskModel(
      taskId: taskId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 'Medium',
      assignedTo: map['assignedTo'] ?? '',
      assignedBy: map['assignedBy'] ?? '',
      familyId: map['familyId'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'familyId': familyId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

  TaskModel copyWith({
    String? taskId,
    String? title,
    String? description,
    String? priority,
    String? assignedTo,
    String? assignedBy,
    String? familyId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      familyId: familyId ?? this.familyId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  // Helper methods
  bool get isPending => status == 'Pending';
  bool get isInProgress => status == 'In Progress';
  bool get isCompleted => status == 'Completed';

  String get priorityColor {
    switch (priority) {
      case 'High':
        return '#FF5252'; // Red
      case 'Medium':
        return '#FF9800'; // Orange
      case 'Low':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }
}

