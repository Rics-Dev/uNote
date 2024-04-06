import 'dart:async';

import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';

class AddTaskToListView extends StatefulWidget {
  const AddTaskToListView({super.key});

  @override
  State<AddTaskToListView> createState() => _AddTaskToListViewState();
}

class _AddTaskToListViewState extends State<AddTaskToListView> {
  final TextEditingController listController = TextEditingController();

  @override
  void dispose() {
    // Dispose the TextEditingController when the widget is disposed
    listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final taskLists = tasksProvider.taskLists;
    // final temporarilyAddedList = tasksProvider.temporarilyAddedList;

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets, // for keyboard
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'List',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: listController,
                    decoration: const InputDecoration(
                      labelText: 'Add Task to List',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (String value) {
                      searchLists(listController
                          .text); // Call searchTags with the updated value
                    },
                    onSubmitted: (_) {
                      if (_.isNotEmpty) {
                        context
                            .read<TasksProvider>()
                            .addTemporarilyAddedList(_);
                        listController.clear();
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: taskLists.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        context
                            .read<TasksProvider>()
                            .addTemporarilyAddedList(taskLists[index].name);
                        Timer(const Duration(milliseconds: 800), () {
                          Navigator.pop(context);
                        });
                      },
                      child: ListTile(
                        leading: MSHCheckbox(
                          style: MSHCheckboxStyle.stroke,
                          colorConfig:
                              MSHColorConfig.fromCheckedUncheckedDisabled(
                            checkedColor: const Color.fromARGB(255, 0, 73, 133),
                          ),
                          size: 22,
                          value: context
                                  .read<TasksProvider>()
                                  .temporarilyAddedList
                                  .name ==
                              taskLists[index].name,
                          onChanged: (bool value) {
                            context
                                .read<TasksProvider>()
                                .addTemporarilyAddedList(taskLists[index].name);
                            Timer(const Duration(milliseconds: 1000), () {
                              Navigator.pop(context);
                            });
                          },
                        ),
                        title: Row(
                          children: [
                            const Icon(Icons.list),
                            Flexible(
                              child: Text(
                                taskLists[index].name,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                        ),
                        // value: taskLists[index].name,
                        // groupValue: taskLists[index],
                        // onChanged: (void value) {
                        //   context
                        //       .read<TasksProvider>()
                        //       .addTemporarilyAddedList(value as String);
                        //   // Navigator.pop(context);
                        // },
                      ),
                    );
                  },
                ),
              ),
              // const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              //   child: const Text('Add'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void searchLists(String text) {}
}
