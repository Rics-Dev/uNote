import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utask/widgets/homePage/add_task_widgets/add_tast_to_list.dart';

import '../../../database/database.dart';
import '../../../providers/taskProvider.dart';
import '../../../providers/task_provider.dart';
import 'package:toastification/toastification.dart';

import 'add_date.dart';
import 'add_priority.dart';
import 'add_tag_modal.dart';
import 'package:intl/intl.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({
    super.key,
  });

  @override
  State<AddTaskView> createState() {
    // Avoid using private types in public APIs.
    return _AddTaskViewState();
  }
}

class _AddTaskViewState extends State<AddTaskView> {
  TextEditingController taskController = TextEditingController();

  @override
  void dispose() {
    // Dispose the TextEditingController when the widget is disposed
    taskController.dispose();
    super.dispose();
  }

  void addTask(String newTask, List<Tag> temporarilyAddedTags,
      String? temporarySelectedPriority) async {
    try {
      await context.read<TasksProvider>().createTask(
            taskContent: newTask,
          );
    } on AppwriteException catch (e) {
      showAlert(title: 'Error', text: e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAPI = context.watch<TasksAPI>();
    final tasksProvider = context.watch<TasksProvider>();
    // final temporarilyAddedTags = tasksAPI.temporarilyAddedTags;
    final temporarilyAddedTags = tasksProvider.temporarilyAddedTags;
    final dueDate = tasksAPI.dueDate;
    String? formattedDate =
        dueDate != null ? DateFormat('EEEE, MMM d, y').format(dueDate) : null;

    final temporarySelectedPriority = tasksAPI.temporarySelectedPriority;

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard
        child: Container(
          padding: const EdgeInsets.all(12.0),
          width: MediaQuery.of(context).size.width * 0.95,
          // height: MediaQuery.of(context).size.height * 0.35,
          // width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    temporarilyAddedTags.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: 105,
                              height: 30,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showAddTagDialog(context);
                                },
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Tags'),
                              ),
                            ),
                          )
                        : IconButton.outlined(
                            onPressed: () {
                              showAddTagDialog(context);
                            },
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Color.fromARGB(255, 0, 73, 133),
                            ),
                          ),
                    temporarilyAddedTags.isEmpty
                        ? const SizedBox(width: 8)
                        : const SizedBox(),
                    Expanded(
                      // width: tags.isEmpty
                      //     ? MediaQuery.of(context).size.width * 0.53
                      //     : MediaQuery.of(context).size.width *
                      //         0.65, // Adjust the width as needed
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: temporarilyAddedTags.map((tag) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Chip(
                                label: Text('#${tag.name}'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                deleteIconColor:
                                    const Color.fromARGB(255, 0, 73, 133),
                                deleteIcon:
                                    const Icon(Icons.close_rounded, size: 18),
                                onDeleted: () {
                                  // context
                                  //     .read<TasksAPI>()
                                  //     .removeTemporarilyAddedTags(tag);
                                  context.read<TasksProvider>().removeTemporarilyAddedTags(tag);
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
                      addTask(taskController.text, temporarilyAddedTags,
                          temporarySelectedPriority);
                      context.read<TasksAPI>().temporarilyAddedTags.clear();
                      Navigator.pop(context, true);
                    } else {
                      toastEmptyTask(context);
                    }
                  },
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    dueDate == null
                        ? IconButton.outlined(
                            onPressed: () {
                              showAddDueDateDialog(context);
                            },
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color.fromARGB(255, 0, 73, 133),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () {
                              showAddDueDateDialog(context);
                            },
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color.fromARGB(255, 0, 73, 133),
                            ),
                            label: Text(formattedDate!),
                          ),
                    IconButton.outlined(
                      onPressed: () {
                        showAddListDialog(context);
                      },
                      icon: const Icon(
                        Icons.format_list_bulleted_rounded,
                        color: Color.fromARGB(255, 0, 73, 133),
                      ),
                    ),
                    temporarySelectedPriority == null
                        ? IconButton.outlined(
                            onPressed: () {
                              showAddPriorityDialog(context);
                            },
                            icon: const Icon(
                              Icons.flag_outlined,
                              color: Color.fromARGB(255, 0, 73, 133),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () {
                              showAddPriorityDialog(context);
                            },
                            icon: const Icon(
                              Icons.flag_outlined,
                              color: Color.fromARGB(255, 0, 73, 133),
                            ),
                            label: Text(temporarySelectedPriority),
                          ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (taskController.text.isNotEmpty) {
                        addTask(taskController.text, temporarilyAddedTags,
                            temporarySelectedPriority);
                        // context.read<TasksAPI>().removeAllTemporaryTags();
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
    );
  }

  Future<dynamic> showAddTagDialog(context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddTagView(),
      isScrollControlled: true,
    ).whenComplete(() => clearSearchedTags());
  }

  Future<dynamic> showAddListDialog(context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddTaskToListView(),
      isScrollControlled: true,
    ).whenComplete(() => clearSearchedTags());
  }

  Future<dynamic> showAddDueDateDialog(context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddDueDateView(),
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() => clearSearchedTags());
  }

  Future<dynamic> showAddPriorityDialog(context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddPriorityView(),
      isScrollControlled: true,
    ).whenComplete(() => clearSearchedTags());
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

  clearSearchedTags() {
    context.read<TasksAPI>().setSearchedTags(context.read<TasksAPI>().tags);
  }
}
