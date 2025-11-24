import 'package:flutter/material.dart';
import 'models/list.dart';

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
    if (text.trim() != '') { // trim gives the text a good haircut with a low taper fade
      setState(() {
        // set state for the thing to refresh or whatever
        tasks.add(Task(text, false));
        _controller.text = ''; // yes this code is human hi
      });
    }


  }
  void toggleTask(Task task, bool? val) { // as you can clearly see, the class here toggles the task, very efficient
    setState(() {
      task.isCompleted = val as bool;
    });
  }

  @override
  void dispose() { // we used this in classroom, i think it just deletes the controller when its not needed, 
                  // looks necessary so i pasted it in
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) { // now for the big part, the part i most likely will not explain in the presentation
                                      // greatest academic comeback this semester just you wait
    return Scaffold(
      appBar: AppBar(
        title: const Text("Functional todo list that just works until you close it"),
        // yeah app bar is just the top bar, wont center it

      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20,)
            // input goes here
            // let me commit first
          ],
        ),
      )
    )
  }
}
