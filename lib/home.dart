import 'package:flutter/material.dart';
import 'models/list.dart';
// You would need to add 'url_launcher' to your pubspec.yaml file
import 'package:url_launcher/url_launcher.dart'; 

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Task> tasks = [
    Task("Task 1", false),
    Task("Task 2", true),
    Task("Task 3", false),
  ];
  //added text editing contorller, we took that in week 7 i think
  final TextEditingController _controller = TextEditingController();
  // underscore means private i think, hi doctor yes im doing this at midnight

  //gonna reduce repition by just making an add classes, insane i know, prob void to avoid return type
  void addTask() {
    String text = _controller.text;
    if (text.trim() != '') {
      // trim gives the text a good haircut with a low taper fade
      setState(() {
        // set state for the thing to refresh or whatever
        tasks.add(Task(text, false));
        _controller.text = ''; // yes this code is human hi
      });
    }
  }

  // Added this function to handle deletion
  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  void toggleTask(Task task, bool? val) {
    // as you can clearly see, the class here toggles the task, very efficient
    setState(() {
      task.isCompleted = val as bool;
    });
  }

  // This is the actual function we'd use to open a URL if 'url_launcher' was installed.
  // I made it async since launch URL requires it when something opens an outside app
  void _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/JosephDoesLinux/material_todo_list');
    
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
            mainAxisSize: MainAxisSize.min, // keep the box small, just big enough for the text
            crossAxisAlignment: CrossAxisAlignment.start, // align the text nicely to the left
            children: [
              const Text(
                'Joseph Abou Antoun, 52330567 \nLIU Project (Phase 1)',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text('Source Code:'),
              // this is the real clickable link now!
              InkWell( // InkWell makes any widget respond to a tap
                onTap: _launchUrl, // now we call the actual launch function
                child: Text(
                  'https://github.com/JosephDoesLinux/material_todo_list',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.primary, // using primary color, looks exactly like a hyperlink
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
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
          // adding the question mark button to show the project info dialog
          IconButton(
            icon: const Icon(Icons.help_outline), // good icon for "info"
            onPressed: () => _showProjectInfo(context), // call the new function
          ),
        ],
      ),
      // we're moving the main layout into a column so we can push the input field to the bottom
      body: Column(
        children: [
          // the list title is still at the top
          const SizedBox(height: 20.0),
          const Text('Your Tasks:', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),

          // this is the main list area, wrapped in Expanded to take up all available space
          // using Card (which we used in Week 5) to give the items a pill-box style
          Expanded(
            // added SingleChildScrollView just in case the list gets too long
            child: SingleChildScrollView(
              child: Column(
                children: tasks.map((Task task) {
                  return Card(
                    // a little margin here makes each task look like a separate pill
                    margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    // using primary container color for that clean Material You background look
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    child: Row(
                      // changed to spaceBetween to neatly push the delete button to the edge
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // basic checkbox
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (bool? val) {
                            toggleTask(task, val);
                          },
                          // Make the active color use the theme's primary color, looks more integrated
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        // Display text, change color if done
                        // apparently this part is like flex, i think we used it before but i honestly had to google this one
                        Expanded(
                          // Adding a little horizontal padding for text cleanliness
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            child: Text(
                              task.toString(),
                              style: TextStyle(
                                fontSize: 18.0,
                                // Fixed: Use onSurface color for default text to ensure dark mode compatibility
                                color: task.isCompleted ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
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
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error)
                        )
                      ],
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
              children: [
                // input goes here
                Expanded(
                  child: SizedBox(
                    height: 50.0,
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a new task',
                        // this padding helps the hint text look right in the Material You box
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                ),
                // this is the floating action button replacement!
                // it looks way cleaner than a regular elevated button for adding one item
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: addTask,
                  // using the theme's primary color for the icon so it changes with the Material You scheme
                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}