import 'package:flutter/material.dart';
import 'models/list.dart';
import 'package:http/http.dart' as http;

// this is the page where we see the details of the task
// we can edit or delete the task from here
class DetailsPage extends StatefulWidget {
  final Task task;

  const DetailsPage({super.key, required this.task});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  // controllers for the text fields so we can get the text out of them
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    // initializing the controllers with the task data
    // so the fields are not empty when we open the page
    _titleController = TextEditingController(text: widget.task.title);
    _detailsController = TextEditingController(text: widget.task.details);
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    // disposing the controllers to free up memory
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  // function to save the changes made to the task
  void saveTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final uri = Uri.parse("$baseUrl/editTask.php");
    try {
      // sending the updated data to the server
      await http.post(
        uri,
        body: {
          "id": widget.task.id.toString(),
          "title": _titleController.text,
          "details": _detailsController.text,
          "is_completed": (_isCompleted ? 1 : 0).toString(),
        },
      );
      // if the widget is still on the screen, go back to the previous page
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      print("Error updating task: $error");
    }
  }

  // function to delete the task
  void deleteTask() async {
    final uri = Uri.parse("$baseUrl/deleteTask.php");
    try {
      // sending the id of the task to be deleted
      await http.post(uri, body: {"id": widget.task.id.toString()});
      // go back to the previous page after deleting
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
        // using the inverse primary color for the app bar
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // delete button in the app bar
          IconButton(icon: const Icon(Icons.delete), onPressed: deleteTask),
        ],
      ),
      body: Padding(
        // padding adds space around the edges so content isn't stuck to the screen
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // column arranges widgets vertically, from top to bottom
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // row arranges widgets horizontally, side by side
              children: [
                Expanded(
                  // expanded makes the text field take up all available horizontal space
                  // leaving just enough room for the checkbox
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
                const SizedBox(
                  width: 8.0,
                ), // sizedbox adds a little gap between the text field and checkbox
                // checkbox to mark the task as completed
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
            const SizedBox(
              height: 16.0,
            ), // adds vertical space between the title row and details
            Expanded(
              // expanded here makes the details text field fill the rest of the screen height
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 65.0,
                ), // extra padding at bottom so FAB doesn't cover text
                // text field for the details
                // expands to fill the available space
                child: TextField(
                  controller: _detailsController,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Details',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floating action button to save the changes
      floatingActionButton: FloatingActionButton(
        onPressed: saveTask,
        child: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
