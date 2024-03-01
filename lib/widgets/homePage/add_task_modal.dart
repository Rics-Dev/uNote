import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import 'package:toastification/toastification.dart';

import 'add_tag_modal.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({
    super.key,
  });

  @override
  _AddTaskViewState createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  // bool showAddTagDialog = false;
  TextEditingController taskController = TextEditingController();
  bool isFavorite = false;
  List<String> tags = [];

  void setIsFavorite(bool value) {
    setState(() {
      isFavorite = value;
    });
  }

  void addTask(String newTask, List<String> tags) async {
    try {
      await context.read<TasksAPI>().createTask(task: newTask, tags: tags);
    } on AppwriteException catch (e) {
      showAlert(title: 'Error', text: e.message.toString());
    }
  }

  void _showAddTagDialog() async {
    List<String>? selectedTags = await showModalBottomSheet(
      context: context,
      builder: (context) => AddTagView(tags),
      isScrollControlled: true,
    );
    // ).whenComplete(() => setState(() {
    //       showAddTagDialog = !showAddTagDialog;
    //     }));

    if (selectedTags != null) {
      // Handle the selected tags here

      setState(() {
        tags = selectedTags;
      });
      // Add your logic to update the tags in the task model or wherever needed
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
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
              height: MediaQuery.of(context).size.height *
                  0.40, // 30% of screen height
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      tags.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: 105,
                                height: 30,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Add your tag logic here
                                    _showAddTagDialog();
                                    print('Add Tag button pressed');
                                  },
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Tags'),
                                ),
                              ),
                            )
                          : MaterialButton(
                              onPressed: () {
                                _showAddTagDialog();
                              },
                              shape: const CircleBorder(
                                  side: BorderSide(
                                color: Color.fromARGB(255, 0, 73, 133),
                              )),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Color.fromARGB(255, 0, 73, 133),
                              ),
                            ),
                      tags.isEmpty
                          ? const SizedBox(width: 8)
                          : const SizedBox(),
                      SizedBox(
                        width: tags.isEmpty
                            ? MediaQuery.of(context).size.width * 0.53
                            : MediaQuery.of(context).size.width *
                                0.65, // Adjust the width as needed
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: tags.map((tag) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Chip(
                                  label: Text('#$tag'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  deleteIconColor:
                                      const Color.fromARGB(255, 0, 73, 133),
                                  deleteIcon:
                                      const Icon(Icons.close_rounded, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      tags.remove(tag);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: taskController,
                    // autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter Task',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.text, // Set appropriate keyboard type
                    textInputAction:
                        TextInputAction.done, // Dismiss keyboard on Done
                    onSubmitted: (_) {
                      if (taskController.text.isNotEmpty) {
                        addTask(taskController.text, tags);
                        Navigator.pop(context, true);
                      } else {
                        toastEmptyTask(context);
                      }
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
                        if (taskController.text.isNotEmpty) {
                          addTask(taskController.text, tags);
                          Navigator.pop(context, true);
                        } else {
                          toastEmptyTask(context);
                        }
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

  ToastificationItem toastEmptyTask(BuildContext context) {
    return toastification.show(
      type: ToastificationType.warning,
      style: ToastificationStyle.minimal,
      context: context,
      title: const Text("Task can't be empty"),
      autoCloseDuration: const Duration(seconds: 3),
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


