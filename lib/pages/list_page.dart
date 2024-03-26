import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:utask/providers/taskProvider.dart';

import '../providers/list_provider.dart';
import 'package:toastification/toastification.dart';

import '../providers/task_provider.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController listController = TextEditingController();

  @override
  void dispose() {
    listController.dispose();
    super.dispose();
  }

  void addList(String listName) async {
    final existingListDocument =
        await context.read<ListsAPI>().verifyExistingList(listName);
    if (existingListDocument == 0) {
      context.read<ListsAPI>().createList(listName);
      listController.clear();
    } else {
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.minimal,
        context: context,
        title: const Text("List already exists"),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
    // Add list to the database
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final taskLists = tasksProvider.taskLists;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            child: TextField(
              controller: listController,
              maxLines: 1,
              onSubmitted: (value) {
                addList(value);
              },
              decoration: InputDecoration(
                suffix: const Text('Add'),
                suffixIcon: GestureDetector(
                  onTap: () {
                    addList(listController.text);
                  },
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color.fromARGB(255, 0, 73, 133),
                  ),
                ),
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 0, 73, 133),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 235, 235, 235),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                hintText: 'Add a List',
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: taskLists.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onLongPress: () {
                          // context
                          //     .read<TasksProvider>()
                          //     .deleteList(taskLists[index].id);
                          // showDialog(
                          //   context: context,
                          //   builder: (context) {
                          //     return AlertDialog(
                          //       title: const Text('Delete List'),
                          //       content: const Text(
                          //           'Are you sure you want to delete this list?'),
                          //       actions: [
                          //         TextButton(
                          //           onPressed: () {
                          //             Navigator.pop(context);
                          //           },
                          //           child: const Text('Cancel'),
                          //         ),
                          //         TextButton(
                          //           onPressed: () {
                          //             // context
                          //             //     .read<TasksProvider>()
                          //             //     .deleteList(taskLists[index].id);
                          //             Navigator.pop(context);
                          //           },
                          //           child: const Text('Delete'),
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // );
                        },
                        child: ExpansionTile(
                          leading: const Icon(Icons.list),
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          textColor: Colors.white,
                          collapsedTextColor: Colors.white,
                          collapsedBackgroundColor:
                              const Color.fromARGB(255, 0, 73, 133),
                          backgroundColor:
                              const Color.fromARGB(255, 0, 73, 133),
                          childrenPadding: const EdgeInsets.only(left: 20),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          initiallyExpanded: true,
                          title: Row(
                            children: [
                              Text(
                                taskLists[index].name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  // borderRadius: BorderRadius.circular(20),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  taskLists[index].tasks.length.toString(),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: taskLists[index].tasks.length,
                              itemBuilder: (context, taskIndex) {
                                return ListTile(
                                  leading: MSHCheckbox(
                                    size: 22,
                                    value: taskLists[index]
                                        .tasks[taskIndex]
                                        .isDone,
                                    // colorConfig: MSHColorConfig
                                    //     .fromCheckedUncheckedDisabled(
                                    //   checkedColor:
                                    //       const Color.fromARGB(255, 0, 73, 133),

                                    // ),
                                    style: MSHCheckboxStyle.fillScaleColor,
                                    onChanged: (selected) {
                                      context.read<TasksProvider>().updateTask(
                                          taskLists[index].tasks[taskIndex].id,
                                          selected);
                                    },
                                  ),
                                  textColor: Colors.white,
                                  title: Text(
                                    taskLists[index].tasks[taskIndex].name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
