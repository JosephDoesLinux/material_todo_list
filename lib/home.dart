import 'package:flutter/material.dart';
import 'models/list.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// You would need to add 'url_launcher' to your pubspec.yaml file
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  void getTasks() async {
    final uri = Uri.parse("http://localhost/material_todo_list/getTasks.php");
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          tasks.clear();
          for (var item in jsonResponse) {
            tasks.add(
              Task(
                int.parse(item['id'].toString()),
                item['title'].toString(),
                item['details']?.toString() ?? "",
                item['is_completed'].toString() == '1',
              ),
            );
          }
        });
      }
    } catch (error) {
      print("Error fetching tasks: $error");
    }
  }

  void addTask() async {
    String text = _controller.text;
    if (text.trim() != '') {
      final uri = Uri.parse("http://localhost/material_todo_list/addTask.php");
      try {
        await http.post(uri, body: {"title": text, "details": ""});
        _controller.text = '';
        getTasks();
      } catch (error) {
        print("Error adding task: $error");
      }
    }
  }

  void deleteTask(Task task) async {
    final uri = Uri.parse("http://localhost/material_todo_list/deleteTask.php");
    try {
      await http.post(uri, body: {"id": task.id.toString()});
      getTasks();
    } catch (error) {
      print("Error deleting task: $error");
    }
  }

  void toggleTask(Task task, bool? val) async {
    final uri = Uri.parse("http://localhost/material_todo_list/updateTask.php");
    try {
      await http.post(
        uri,
        body: {
          "id": task.id.toString(),
          "is_completed": (val == true ? 1 : 0).toString(),
        },
      );
      getTasks();
    } catch (error) {
      print("Error updating task: $error");
    }
  }

  void _launchUrl() async {
    final Uri url = Uri.parse(
      'https://github.com/JosephDoesLinux/material_todo_list',
    );

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showProjectInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Project Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Joseph Abou Antoun, 52330567 \nLIU Project (Phase 1)',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text('Source Code:'),
              InkWell(
                onTap: _launchUrl,
                child: Text(
                  'https://github.com/JosephDoesLinux/material_todo_list',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Material To-Do List"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showProjectInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20.0),
          const Text(
            'Your Tasks:',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: tasks.map((Task task) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (bool? val) {
                            toggleTask(task, val);
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: task.isCompleted
                                        ? Colors.grey
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  task.details,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: task.isCompleted
                                        ? Colors.grey
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            deleteTask(task);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.0,
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a new task',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: addTask,
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
