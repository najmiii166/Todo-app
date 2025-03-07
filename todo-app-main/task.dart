import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String? id;
  String title;
  String description;
  DateTime dateTime;
  bool isCompleted;
  String userUid; // Link tasks to a specific user
  bool isFavorite; // Field for favorite status

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.isCompleted,
    required this.userUid, // Include userUid
    this.isFavorite = false, // Default favorite status is false
  });

  /// Convert Task object to a Map to save in Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'userUid': userUid, // Store userUid in Firestore
      'isFavorite': isFavorite, // Store favorite status in Firestore
    };
  }

  /// Create a Task object from a Firestore document snapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id, // Use Firestore document ID
      title: data['title'] ?? '', // Default to empty string if null
      description: data['description'] ?? '', // Default to empty string if null
      dateTime: DateTime.parse(data['dateTime']),
      isCompleted: data['isCompleted'] ?? false,
      userUid: data['userUid'] ?? '',
      isFavorite: data['isFavorite'] ?? false, // Default favorite status is false
    );
  }
}
