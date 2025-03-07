import 'package:flutter/material.dart';
import 'task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle; // For completing the task
  final VoidCallback onFavoriteToggle; // For toggling favorite status

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circle Checkbox (Left side)
            GestureDetector(
              onTap: onToggle,
              child: Container(
                margin: const EdgeInsets.all(12),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? Colors.green : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                child: task.isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
            // Task Details (Title, Description, and Date/Time)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? Colors.grey : Colors.black,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4), // Spacing between title and description
                    // Task Description
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8), // Spacing before date and time
                    // Date and Time
                    Text(
                      "${task.dateTime.toLocal().toString().split(' ')[0]} • "
                          "${task.dateTime.hour.toString().padLeft(2, '0')}:${task.dateTime.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            // Favorite Icon (Right side)
            IconButton(
              icon: Icon(
                task.isFavorite ? Icons.star : Icons.star_border,
                color: task.isFavorite ? Colors.yellow : Colors.grey,
                size: 24,
              ),
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
      ),
    );
  }
}
