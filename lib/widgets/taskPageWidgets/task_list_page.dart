import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:utask/providers/task_provider.dart';

import '../../models/entities.dart';
import 'package:toastification/toastification.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final ExpansionTileController controller = ExpansionTileController();
  final TextEditingController listController = TextEditingController();

  bool isAddingList = false;

  @override
  void dispose() {
    listController.dispose();
    super.dispose();
  }

  void addList(String listName) {
    final existingListDocument =
        context.read<TasksProvider>().verifyExistingList(listName);
    if (existingListDocument == null) {
      context.read<TasksProvider>().addList(listName);
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
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final taskLists = tasksProvider.taskLists;

    List<bool> isKeyBoardOpenedList = tasksProvider.isKeyBoardOpenedList;
    List<List<bool>> isEditingTask = tasksProvider.isEditingTask;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isAddingList = true;
            });
          },
          child: AnimatedContainer(
            width: isAddingList
                ? MediaQuery.of(context).size.width * 0.8
                : MediaQuery.of(context).size.width * 0.45,
            // height: 60,
            duration: const Duration(milliseconds: 300),
            child: TextField(
              onTap: () {
                setState(() {
                  isAddingList = true;
                });
              },
              controller: listController,
              maxLines: 1,
              onSubmitted: (value) {
                addList(value);
                setState(() {
                  isAddingList = false;
                });
              },
              // style: ,
              decoration: InputDecoration(
                suffix: const Text('Add'),
                prefixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      isAddingList = true;
                    });
                  },
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    // color: Color.fromARGB(255, 0, 73, 133),
                  ),
                ),
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  // color: Color.fromARGB(255, 0, 73, 133),
                ),
                filled: true,
                // fillColor: const Color.fromARGB(255, 235, 235, 235),

                // border: const OutlineInputBorder(
                //   borderSide: BorderSide.none,
                //   borderRadius: BorderRadius.all(
                //     Radius.circular(50),
                //   ),
                // ),
                // border: InputBorder.none,
                hintText: 'Add a List',
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: taskLists.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 12),
                child: GestureDetector(
                  onLongPress: () {
                    deleteListDialog(context, taskLists, index);
                  },
                  child: Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(taskLists[index].id.toString()),
                    onDismissed: (direction) {
                      context
                          .read<TasksProvider>()
                          .deleteList(taskLists[index].id);
                    },
                    confirmDismiss: (direction) {
                      return deleteListDialog(context, taskLists, index);
                    },
                    background: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        )
                      ],
                    ),
                    child: ExpansionTile(
                      // tilePadding: const EdgeInsets.all(8),
                      onExpansionChanged: (value) {
                        if (value) {
                          setState(() {
                            isAddingList = false;
                          });
                          context
                              .read<TasksProvider>()
                              .setIsKeyboardOpened(false, index);
                          context
                              .read<TasksProvider>()
                              .setIsEditingTask(false, index, -1);
                        }
                      },
                      initiallyExpanded: false,
                      leading: const Icon(Icons.list),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      textColor: Colors.white,
                      collapsedTextColor: Colors.white,

                      collapsedBackgroundColor:
                          const Color.fromARGB(255, 0, 73, 133),
                      backgroundColor: const Color.fromARGB(255, 0, 73, 133),
                      // collapsedBackgroundColor: Colors.blue[100],
                      // backgroundColor: Colors.blue[100],
                      // collapsedBackgroundColor: const Color(0xFFF7F7F7),
                      // backgroundColor: const Color(0xFFF7F7F7),
                      childrenPadding: const EdgeInsets.only(left: 20),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  taskLists[index].tasks.sort((a, b) {
                                    if (a.isDone && !b.isDone) {
                                      return 1;
                                    } else if (!a.isDone && b.isDone) {
                                      return -1;
                                    } else {
                                      return 0;
                                    }
                                  });
                                });
                              },
                              child: Text(
                                taskLists[index].name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Visibility(
                            visible: taskLists[index].tasks.isNotEmpty,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                taskLists[index].tasks.length.toString(),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                ExpansionTileController.of(context).expand();
                                context
                                    .read<TasksProvider>()
                                    .setIsKeyboardOpened(
                                        !isKeyBoardOpenedList[index], index);
                              },
                              child: const Icon(Icons.add),
                            );
                          }),
                        ],
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: taskLists[index].tasks.length,
                          itemBuilder: (context, taskIndex) {
                            return ListTile(
                              trailing: PullDownButton(
                                itemBuilder: (context) => [
                                  PullDownMenuItem(
                                    icon: Icons.delete,
                                    isDestructive: true,
                                    title: 'Delete',
                                    onTap: () {
                                      context.read<TasksProvider>().deleteTask(
                                          taskLists[index].tasks[taskIndex].id);
                                    },
                                  ),
                                ],
                                buttonBuilder: (context, showMenu) =>
                                    IconButton(
                                  onPressed: showMenu,
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              leading: MSHCheckbox(
                                size: 27,
                                value: taskLists[index].tasks[taskIndex].isDone,
                                style: MSHCheckboxStyle.fillScaleCheck,
                                onChanged: (selected) {
                                  context.read<TasksProvider>().updateTask(
                                      taskLists[index].tasks[taskIndex].id,
                                      selected);
                                },
                              ),
                              textColor: Colors.white,
                              title: GestureDetector(
                                onTap: () {
                                  context
                                      .read<TasksProvider>()
                                      .setIsEditingTask(true, index, taskIndex);
                                },
                                child: isEditingTask[index][taskIndex]
                                    ? TextFormField(
                                        initialValue: taskLists[index]
                                            .tasks[taskIndex]
                                            .name,
                                        autofocus: true,
                                        onFieldSubmitted: (value) {
                                          context
                                              .read<TasksProvider>()
                                              .updateTaskName(
                                                  taskLists[index]
                                                      .tasks[taskIndex]
                                                      .id,
                                                  value);
                                          context
                                              .read<TasksProvider>()
                                              .setIsEditingTask(
                                                  false, index, taskIndex);
                                        },
                                        cursorColor: Colors.white,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          hintStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Color.fromARGB(255, 0, 73, 133),
                                          ),
                                          filled: false,
                                          fillColor: Color.fromARGB(
                                              255, 235, 235, 235),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          hintText: 'Edit Task',
                                        ),
                                      )
                                    : Text(
                                        taskLists[index].tasks[taskIndex].name,
                                        style: TextStyle(
                                          decoration: taskLists[index]
                                                  .tasks[taskIndex]
                                                  .isDone
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: taskLists[index]
                                                  .tasks[taskIndex]
                                                  .isDone
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        isKeyBoardOpenedList[index]
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0, 0.0, 8.0, 12.0),
                                child: ListTile(
                                  trailing: PullDownButton(
                                    itemBuilder: (context) => [
                                      PullDownMenuItem(
                                        icon: Icons.delete,
                                        isDestructive: true,
                                        title: 'Delete',
                                        onTap: () {
                                          // context
                                          //     .read<TasksProvider>()
                                          //     .deleteTask(taskLists[index]
                                          //         .tasks[taskIndex]
                                          //         .id);
                                        },
                                      ),
                                    ],
                                    buttonBuilder: (context, showMenu) =>
                                        IconButton(
                                      onPressed: showMenu,
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  leading: MSHCheckbox(
                                    size: 24,
                                    value: false,
                                    style: MSHCheckboxStyle.fillScaleCheck,
                                    onChanged: (selected) {},
                                  ),
                                  title: TextField(
                                    autofocus: true,
                                    onSubmitted: (value) {
                                      context
                                          .read<TasksProvider>()
                                          .setTemporaySelectedList(
                                              taskLists[index]);
                                      context.read<TasksProvider>().addTask(
                                            value,
                                          );
                                      context
                                          .read<TasksProvider>()
                                          .setIsKeyboardOpened(
                                              !isKeyBoardOpenedList[index],
                                              index);
                                    },
                                    cursorColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      suffix: const Text('Add'),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          context.read<TasksProvider>().addTask(
                                                listController.text,
                                              );
                                          context
                                              .read<TasksProvider>()
                                              .setIsKeyboardOpened(
                                                  !isKeyBoardOpenedList[index],
                                                  index);
                                        },
                                        child: const Icon(
                                          Icons.add_circle_outline_rounded,
                                          color:
                                              Color.fromARGB(255, 0, 73, 133),
                                        ),
                                      ),
                                      hintStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 0, 73, 133),
                                      ),
                                      filled: false,
                                      fillColor: const Color.fromARGB(
                                          255, 235, 235, 235),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      hintText: 'Add a Task',
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Future<bool?> deleteListDialog(
      BuildContext context, List<TaskList> taskLists, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete List? "${taskLists[index].name}"'),
          content: const Text('Are you sure you want to delete this list ?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3.0,
                  ),
                  onPressed: () {
                    // Save changes
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      context
                          .read<TasksProvider>()
                          .deleteList(taskLists[index].id);
                      Navigator.pop(context);
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        );
      },
    );
  }
}
