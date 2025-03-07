import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

class TaskCreationDialog extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final Task? task; // Nullable for editing
  final bool isEditing;
  final String userUid; // Required userUid for associating the task with a user

  const TaskCreationDialog({
    Key? key,
    required this.onTaskAdded,
    this.task,
    required this.isEditing,
    required this.userUid,
  }) : super(key: key);

  @override
  _TaskCreationDialogState createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDateTime;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedDateTime = widget.task?.dateTime ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _saveTaskToDatabase(Task task) async {
    try {
      setState(() {
        _isLoading = true; // Prevent duplicate submissions
      });

      if (widget.isEditing && (task.id?.isNotEmpty ?? false)) {
        // Update existing task
        await _firestore.collection('tasks').doc(task.id).update(task.toFirestore());
      } else {
        // Create a new task and generate a unique ID
        final docRef = _firestore.collection('tasks').doc();
        task.id = docRef.id; // Assign the document's unique ID to the task
        await docRef.set(task.toFirestore());
      }

      widget.onTaskAdded(task); // Notify parent about the update
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving task: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Text
                Text(
                  widget.isEditing ? "Edit Task" : "Create Task",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 15),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Task Title",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  validator: (value) =>
                  (value?.isNotEmpty ?? false) ? null : 'Title is required',
                ),
                SizedBox(height: 15),

                // Description Field with Validation
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  validator: (value) {
                    if ((value?.isEmpty ?? true)) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Date Picker
                ListTile(
                  leading: Icon(Icons.date_range, color: Colors.blue),
                  title: Text(
                    "Date: ${_selectedDateTime.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(color: Colors.black87),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: _pickDate,
                  ),
                ),

                // Time Picker
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blue),
                  title: Text(
                    "Time: ${TimeOfDay.fromDateTime(_selectedDateTime).format(context)}",
                    style: TextStyle(color: Colors.black87),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.access_time, color: Colors.blue),
                    onPressed: _pickTime,
                  ),
                ),

                // Buttons (Cancel and Save)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                    SizedBox(width: 10),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final newTask = Task(
                            id: widget.task?.id ?? '',
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            dateTime: _selectedDateTime,
                            userUid: widget.userUid,
                            isCompleted: widget.task?.isCompleted ?? false,
                          );
                          _saveTaskToDatabase(newTask);
                        }
                      },
                      child: Text(widget.isEditing ? "Update" : "Create"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
