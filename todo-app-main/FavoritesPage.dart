import 'package:flutter/material.dart';
import 'task.dart';
import 'task_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatelessWidget {
  final String userUid;

  FavoritesPage({required this.userUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Imprtant")),
      body: _buildFavoriteTaskList(),
    );
  }

  // Fetch tasks where 'isFavorite' is true
  Widget _buildFavoriteTaskList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userUid', isEqualTo: userUid)
          .where('isFavorite', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final tasks = snapshot.data?.docs.map((doc) => Task.fromFirestore(doc)).toList() ?? [];

        if (tasks.isEmpty) {
          return Center(
            child: Text("No Favorite Tasks Yet!", style: TextStyle(color: Colors.grey, fontSize: 16)),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => TaskCard(
            task: tasks[index],
            onToggle: () => _toggleTaskCompletion(tasks[index]),
            onFavoriteToggle: () => _toggleFavorite(tasks[index]),
          ),
        );
      },
    );
  }

  // Toggle task completion and update Firestore
  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
        'isCompleted': !task.isCompleted,
      });
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  // Toggle task favorite status and update Firestore
  Future<void> _toggleFavorite(Task task) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
        'isFavorite': !task.isFavorite,
      });
    } catch (e) {
      print('Error updating favorite: $e');
    }
  }
}
