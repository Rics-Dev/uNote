import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../models/entities.dart';
import '../../providers/task_provider.dart';

class TaskInboxPage extends StatelessWidget {
  const TaskInboxPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    List<Task> tasks = tasksProvider.tasks;

    if (tasksProvider.isSearchingTasks) {
      tasks = tasksProvider.searchedTasks;
    } else if (tasksProvider.filteredTasks.isNotEmpty ||
        (tasksProvider.filteredTasks.isEmpty &&
            tasksProvider.selectedPriority.isNotEmpty) ||
        (tasksProvider.filteredTasks.isEmpty &&
            tasksProvider.selectedTags.isNotEmpty)) {
      tasks = tasksProvider.filteredTasks;
    } else {
      tasks = tasksProvider.tasks;
    }

    tasks = tasks.where((task) => task.list.target == null).toList();

    return tasks.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No tasks Yet! Add a task to get started!'),
                SizedBox(height: 40),
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 50,
                  color: Color.fromARGB(255, 0, 73, 133),
                )
              ],
            ),
          )
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return LongPressDraggable(
                dragAnchorStrategy:
                    (Draggable<Object> _, BuildContext __, Offset ___) =>
                        const Offset(70, 70),
                key: ValueKey(tasks[index]),
                data: tasks[index].id,
                onDragStarted: () {
                  context.read<TasksProvider>().startDrag(index);
                },
                onDragEnd: (data) {
                  context.read<TasksProvider>().endDrag();
                },
                feedback: Card(
                  color: Colors.blue[100],
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(tasks[index].name),
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ListTile(
                    leading: MSHCheckbox(
                      size: 26,
                      value: tasks[index].isDone,
                      style: MSHCheckboxStyle.fillScaleCheck,
                      colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                        checkedColor: const Color.fromARGB(255, 0, 73, 133),
                      ),
                      onChanged: (selected) {
                        context
                            .read<TasksProvider>()
                            .updateTask(tasks[index].id, selected);
                      },
                    ),
                    title: Text(
                      tasks[index].name,
                      style: TextStyle(
                        fontSize: 14,
                        decoration: tasks[index].isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: tasks[index].isDone ? Colors.grey : null,
                      ),
                    ),
                    trailing: PullDownButton(
                      itemBuilder: (context) => [
                        // PullDownMenuItem(
                        //   icon: Icons.edit,
                        //   title: 'Edit',
                        //   onTap: () {
                        //     showTaskDetails(context, tasks[index]);
                        //   },
                        // ),
                        PullDownMenuItem(
                          icon: Icons.delete,
                          isDestructive: true,
                          title: 'Delete',
                          onTap: () {
                            context
                                .read<TasksProvider>()
                                .deleteTask(tasks[index].id);
                          },
                        ),
                      ],
                      buttonBuilder: (context, showMenu) => IconButton(
                        onPressed: showMenu,
                        icon: const Icon(
                          Icons.more_vert,
                          // color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Future<dynamic> showTaskDetails(BuildContext context, Task task) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Task',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: task.name,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: 'This is an example task description.',
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Task Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Cancel editing
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 0, 73, 133),
                            ),
                          ),
                          onPressed: () {
                            // Save changes
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
