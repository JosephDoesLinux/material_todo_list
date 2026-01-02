import 'package:flutter/material.dart';
import 'models/list.dart';
import 'package:http/http.dart' as http;

class DetailsPage extends StatefulWidget {
  final Task task;

  const DetailsPage({super.key, required this.task});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _detailsController = TextEditingController(text: widget.task.details);
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void saveTask() async {
    final uri = Uri.parse("http://localhost/material_todo_list/editTask.php");
    try {
      await http.post(
        uri,
        body: {
          "id": widget.task.id.toString(),
          "title": _titleController.text,
          "details": _detailsController.text,
          "is_completed": (_isCompleted ? 1 : 0).toString(),
        },
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      print("Error updating task: $error");
    }
  }

  void deleteTask() async {
    final uri = Uri.parse("http://localhost/material_todo_list/deleteTask.php");
    try {
      await http.post(uri, body: {"id": widget.task.id.toString()});
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      print("Error deleting task: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: deleteTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Checkbox(
                  value: _isCompleted,
                  onChanged: (val) {
                    setState(() {
                      _isCompleted = val ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _detailsController,
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveTask,
        child: const Icon(Icons.save),
      ),
    );
  }
}
