import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'task.dart';
import 'task_card.dart';
import 'task_creation_dialog.dart';
import 'FavoritesPage.dart'; // Import the FavoritesPage

class TaskHome extends StatefulWidget {
  String profileName; // Make profileName mutable
  final String userUid;

  TaskHome({required this.profileName, required this.userUid});

  @override
  State<TaskHome> createState() => _TaskHomeState();
}

class _TaskHomeState extends State<TaskHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Lighter background color for a softer look
      appBar: _buildAppBar(),
      body: _buildTaskList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent, // Softer blue shade
        onPressed: () => _showTaskCreationDialog(isEditing: false),
        child: Icon(Icons.add, color: Colors.white),
      ),
      drawer: _buildDrawer(),
    );
  }

  // AppBar with user info and gradient color
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blueAccent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: _buildAppBarContent(),
    );
  }

  // AppBar content with profile name and greeting
  Row _buildAppBarContent() {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, I'm",
                style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text(widget.profileName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  // Real-time task list
  Widget _buildTaskList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tasks')
          .where('userUid', isEqualTo: widget.userUid)
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
            child: Text(
              "No Tasks Yet!",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
        );
      },
    );
  }

  // Task Card with swipe to delete and double tap to edit
  Widget _buildTaskCard(Task task) {
    return GestureDetector(
      onDoubleTap: () => _showTaskCreationDialog(isEditing: true, task: task),
      child: Dismissible(
        key: Key(task.id ?? ''),
        background: Container(
          color: Colors.redAccent,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _deleteTask(task.id ?? ''),
        child: TaskCard(
          task: task,
          onToggle: () => _toggleTaskCompletion(task),
          onFavoriteToggle: () => _toggleFavorite(task),
        ),
      ),
    );
  }

  // Toggle task completion and update Firestore
  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'isCompleted': !task.isCompleted,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Toggle task favorite status and update Firestore
  Future<void> _toggleFavorite(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'isFavorite': !task.isFavorite,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Delete task
  Future<void> _deleteTask(String taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel deletion
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Show task creation/edit dialog
  void _showTaskCreationDialog({required bool isEditing, Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskCreationDialog(
        onTaskAdded: (_) {},
        isEditing: isEditing,
        task: task,
        userUid: widget.userUid,
      ),
    );
  }

  // Drawer with profile name edit and logout
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Name'),
            onTap: () {
              Navigator.pop(context);
              _showEditProfileNameDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.star), // Changed heart icon to star
            title: Text('Important'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage(userUid: widget.userUid)),
              );
            },
          ),
        ],
      ),
    );
  }

  // Drawer header with a profile picture
  DrawerHeader _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.blueAccent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
          ),
          SizedBox(height: 10),
          Text("Hello, I'm",
              style: TextStyle(fontSize: 12, color: Colors.white70)),
          Text(widget.profileName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // Dialog for editing profile name
  void _showEditProfileNameDialog() {
    final TextEditingController nameController =
    TextEditingController(text: widget.profileName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile Name"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "New Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    setState(() {
                      widget.profileName = newName;
                    });
                    await _firestore
                        .collection('users')
                        .doc(widget.userUid)
                        .update({'name': newName});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Name updated successfully!'), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating name: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
