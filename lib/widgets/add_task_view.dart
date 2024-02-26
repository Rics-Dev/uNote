import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/task.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({
    super.key,
  });

  @override
  _AddTaskViewState createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  TextEditingController taskController = TextEditingController();
  bool isFavorite = false;

  void setIsFavorite(bool value) {
    setState(() {
      isFavorite = value;
    });
  }

  void addTask(String newTask) async {
    try {
      await context.read<TasksAPI>().createTask(task: newTask);
    } on AppwriteException catch (e) {
      showAlert(title: 'Error', text: e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      // Use Wrap widget to center the content vertically
      children: [
        Center(
          // Center the content vertically
          child: Padding(
            padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard
            child: Container(
              padding: const EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height *
                  0.30, // 30% of screen height
              child: Column(
                children: [
                  TextField(
                    controller: taskController,
                    autofocus: true, // Automatically focus the input field
                    decoration: const InputDecoration(
                      labelText: 'Enter Task',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.text, // Set appropriate keyboard type
                    textInputAction:
                        TextInputAction.done, // Dismiss keyboard on Done
                    onSubmitted: (_) {
                      addTask(taskController.text);
                      Navigator.pop(context, true);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border_outlined,
                          color: isFavorite ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          setIsFavorite(!isFavorite); // Update favorite state
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        addTask(taskController.text);
                        Navigator.pop(context, true);
                      }, // Close bottom sheet
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 73, 133),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  showAlert({required String title, required String text}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }
}


// TextButton(
//                         onPressed: () {
//                           Navigator.pop(context); // Close bottom sheet
//                         },
//                         child: const Text('Cancel'),
//                       ),
//                       const SizedBox(width: 10.0),
//                       ElevatedButton(
//                         onPressed: () {
//                           // Handle task submission, e.g.,
//                           _addTask(taskController.text);
//                           Navigator.pop(context); // Close bottom sheet
//                         },
//                         child: const Text('Submit'),
//                       ),







                  