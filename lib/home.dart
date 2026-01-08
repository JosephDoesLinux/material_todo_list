import 'package:flutter/material.dart';
import 'models/list.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// You would need to add 'url_launcher' to your pubspec.yaml file
import 'package:url_launcher/url_launcher.dart';
import 'details.dart';

// this is the main page of the app
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // list to store all the tasks
  List<Task> tasks = [];
  // list to store the tasks that match the search query
  List<Task> filteredTasks = [];
  // loading state
  bool isLoading = true;

  //added text editing contorller, we took that in week 7 i think
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  // underscore means private i think, hi doctor yes im doing this at midnight

  @override
  void initState() {
    super.initState();
    // fetch the tasks when the app starts
    getTasks();
  }

  // function to get the tasks from the server
  void getTasks() async {
    setState(() {
      isLoading = true;
    });
    final uri = Uri.parse("$baseUrl/getTasks.php");
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
          // update the filtered list as well
          _runFilter(_searchController.text);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode}')),
          );
        }
      }
    } catch (error) {
      print("Error fetching tasks: $error");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection Error: $error')));
      }
    }
  }

  // function to filter the tasks based on the search query
  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      // if the search query is empty, show all tasks
      filteredTasks = List.from(tasks);
    } else {
      // otherwise, show only the tasks that match the query
      filteredTasks = tasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(enteredKeyword.toLowerCase()),
          )
          .toList();
    }
  }

  //gonna reduce repition by just making an add classes, insane i know, prob void to avoid return type
  void addTask() async {
    String text = _controller.text;
    if (text.trim() != '') {
      // trim gives the text a good haircut with a low taper fade
      final uri = Uri.parse("$baseUrl/addTask.php");
      try {
        // sending the new task to the server
        final response = await http.post(
          uri,
          body: {"title": text, "details": ""},
        );
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // set state for the thing to refresh or whatever
          _controller.text = ''; // yes this code is human hi

          // Create the new task object
          Task newTask = Task(
            int.parse(jsonResponse['id'].toString()),
            text,
            "",
            false,
          );

          // Add to local list immediately so we don't have to fetch everything again
          setState(() {
            tasks.add(newTask);
            _runFilter(_searchController.text);
          });

          // Navigate to details page
          if (mounted) {
            // wait for the user to come back from the details page
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailsPage(task: newTask),
              ),
            );
            // if the user deleted the task in details page
            if (result == 'delete') {
              setState(() {
                tasks.remove(newTask);
                filteredTasks.remove(newTask);
              });
            } else if (result == true) {
              // changes were already applied to the object, just refresh UI
              setState(() {});
            }
          }
        }
      } catch (error) {
        print("Error adding task: $error");
      }
    }
  }

  // Added this function to handle deletion
  void deleteTask(Task task) async {
    // update the UI immediately by removing the task from the list
    setState(() {
      tasks.removeWhere((t) => t.id == task.id);
      filteredTasks.removeWhere((t) => t.id == task.id);
    });

    final uri = Uri.parse("$baseUrl/deleteTask.php");
    try {
      // tell the server to delete the task
      await http.post(uri, body: {"id": task.id.toString()});
      // no need to call getTasks() anymore since we updated the UI locally
    } catch (error) {
      print("Error deleting task: $error");
    }
  }

  // function to toggle the task completion status
  void toggleTask(Task task, bool? val) async {
    // update the UI immediately
    setState(() {
      task.isCompleted = val ?? false;
    });

    // as you can clearly see, the class here toggles the task, very efficient
    final uri = Uri.parse("$baseUrl/updateTask.php");
    try {
      // update the task status on the server
      await http.post(
        uri,
        body: {
          "id": task.id.toString(),
          "is_completed": (val == true ? 1 : 0).toString(),
        },
      );
      // no need to call getTasks() anymore
    } catch (error) {
      print("Error updating task: $error");
    }
  }

  // This is the actual function we'd use to open a URL if 'url_launcher' was installed.
  // I made it async since launch URL requires it when something opens an outside app
  void _launchUrl() async {
    final Uri url = Uri.parse(
      'https://github.com/JosephDoesLinux/material_todo_list',
    );

    // NOTE TO PROFESSOR: This is where we would call launchUrl(url). package we never took in class but i used google for this one
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  // function to show a message box with project details, like a fancy about page
  void _showProjectInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // using a standard text as the title, nothing too fancy
          title: const Text('Project Information'),
          // using a column here so we can separate the body text and the clickable link
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // keep the box small, just big enough for the text
            crossAxisAlignment:
                CrossAxisAlignment.start, // align the text nicely to the left
            children: [
              const Text(
                'Joseph Abou Antoun, 52330567 \nLIU Project (Phase 1)',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text('Source Code:'),
              // this is the real clickable link now!
              InkWell(
                // InkWell makes any widget respond to a tap
                onTap: _launchUrl, // now we call the actual launch function
                child: Text(
                  'https://github.com/JosephDoesLinux/material_todo_list',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // using primary color, looks exactly like a hyperlink
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
              },
              // using the theme's primary color for the button text, super Material You
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
    // we used this in classroom, i think it just deletes the controller when its not needed,
    // looks necessary so i pasted it in
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // now for the big part, the part i most likely will not explain in the presentation
    // greatest academic comeback this semester just you wait
    return Scaffold(
      appBar: AppBar(
        // Changed the title as requested
        title: const Text("Material To-Do List"),
        // Removed centerTitle: true so the title is left-aligned (the modern Material 3 way)
        // stealing the material 3 inverse primary color so it matches the pixel vibe
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // yeah app bar is just the top bar, wont center it
        // adding a list of widgets here for the action buttons
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline), // good icon for "info"
            onPressed: () => _showProjectInfo(context), // call the new function
          ),
          // refresh button to reload the tasks
          IconButton(icon: const Icon(Icons.refresh), onPressed: getTasks),

          // adding the question mark button to show the project info dialog
        ],
      ),
      // we're moving the main layout into a column so we can push the input field to the bottom
      body: Column(
        // using a column to stack the search bar, list, and input area vertically
        children: [
          Padding(
            // padding around the search bar for breathing room
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _runFilter(value)),
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Text(
            'Your Tasks:',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0), // small gap
          // this is the main list area, wrapped in Expanded to take up all available space
          // using Card (which we used in Week 5) to give the items a pill-box style
          Expanded(
            // expanded is crucial here, it tells the list to take up all remaining vertical space
            // added SingleChildScrollView just in case the list gets too long
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: filteredTasks.map((Task task) {
                        // dismissible widget allows us to swipe the task to delete or edit
                        return Dismissible(
                          key: Key(task.id.toString()),
                          // background for swipe right (edit)
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20.0),
                            child: const Icon(Icons.info, color: Colors.white),
                          ),
                          // background for swipe left (delete)
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          // confirm dismiss is called when the user swipes
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // if swipe left, delete the task
                              return true;
                            } else {
                              // if swipe right, go to details page
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(task: task),
                                ),
                              );
                              if (result == 'delete') {
                                setState(() {
                                  tasks.remove(task);
                                  filteredTasks.remove(task);
                                });
                                return false;
                              } else if (result == true) {
                                setState(() {});
                              }
                              return false;
                            }
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              deleteTask(task);
                            }
                          },
                          child: Card(
                            // a little margin here makes each task look like a separate pill
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            // using primary container color for that clean Material You background look
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.5),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailsPage(task: task),
                                  ),
                                );
                                if (result == 'delete') {
                                  setState(() {
                                    tasks.remove(task);
                                    filteredTasks.remove(task);
                                  });
                                } else if (result == true) {
                                  setState(() {});
                                }
                              },
                              child: Row(
                                // changed to spaceBetween to neatly push the delete button to the edge
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // pushes children to far ends
                                children: [
                                  // basic checkbox
                                  Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (bool? val) {
                                      toggleTask(task, val);
                                    },
                                    // Make the active color use the theme's primary color, looks more integrated
                                    activeColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  // Display text, change color if done
                                  // apparently this part is like flex, i think we used it before but i honestly had to google this one
                                  Expanded(
                                    // expanded here is important so the text takes up the middle space
                                    // and pushes the delete button to the right
                                    // Adding a little horizontal padding for text cleanliness
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 12.0,
                                      ),
                                      child: Column(
                                        // column for title and details stacked vertically
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // align text to left
                                        children: [
                                          Text(
                                            task.title,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              // Fixed: Use onSurface color for default text to ensure dark mode compatibility
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
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Delete Button: Changed from an ElevatedButton to a simpler, cleaner IconButton
                                  // Used ElevatedButton, we took that Week 7, had to google most of it tho since we didnt do much
                                  IconButton(
                                    onPressed: () {
                                      deleteTask(task);
                                    },
                                    // using the system error color so it looks legit instead of just red
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          // this is the new input section at the bottom
          // we use Padding to make sure it doesn't touch the screen edges (looks better on Pixel/Android)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              // row to put input field and add button side by side
              children: [
                // input goes here
                Expanded(
                  // expanded makes the input field take up all width except for the button
                  child: SizedBox(
                    height: 50.0, // fixed height for the input box
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a new task',
                        // this padding helps the hint text look right in the Material You box
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                      ),
                    ),
                  ),
                ),
                // this is the floating action button replacement!
                // it looks way cleaner than a regular elevated button for adding one item
                const SizedBox(width: 8.0), // gap between input and button
                FloatingActionButton(
                  onPressed: addTask,
                  // using the theme's primary color for the icon so it changes with the Material You scheme
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
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
