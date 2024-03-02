import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';

import '../../models/tasks.dart';
import '../../providers/drag_provider.dart';
import '../../providers/task_provider.dart';

class TasksViewInboxPage extends StatelessWidget {
  const TasksViewInboxPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final selectedTags = tasksAPI.selectedTags;

    // final filteredTasks = tasksAPI.filteredTasks;

    // List<Task> filteredTasks =
    //     (selectedTags.isEmpty || tasksAPI.filteredTasks.isEmpty)
    //         ? tasks
    //         : tasksAPI.filteredTasks.isNotEmpty
    //             ? tasksAPI.filteredTasks
    //             : [];

    final tasksAPI = context.watch<TasksAPI>();
    List<Task> tasks = tasksAPI.tasks;
    if (tasksAPI.filteredTasks.isNotEmpty) {
      tasks = tasksAPI.filteredTasks;
    }
    if (tasksAPI.searchedTasks.isNotEmpty) {
      tasks = tasksAPI.searchedTasks;
    }

    final notDoneTasks = tasks.where((task) => !task.isDone).toList();
    final doneTasks = tasks.where((task) => task.isDone).toList();

    return Expanded(
      child: tasks.isEmpty
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
              itemCount: notDoneTasks.length + (doneTasks.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                return buildTaskItem(context, notDoneTasks, doneTasks, index);
              },
            ),
    );
  }

  Widget buildTaskItem(
    BuildContext context,
    List<dynamic> notDoneTasks,
    List<dynamic> doneTasks,
    int index,
  ) {
    if (index < notDoneTasks.length) {
      return buildTaskWidget(context, notDoneTasks[index], index);
    } else {
      return doneTasks.isNotEmpty
          ? doneTasksList(context, doneTasks, index)
          : const SizedBox();
    }
  }

  Widget buildTaskWidget(BuildContext context, Task task, index) {
    return LongPressDraggable(
      dragAnchorStrategy: (Draggable<Object> _, BuildContext __, Offset ___) =>
          const Offset(70, 70),
      key: ValueKey(task),
      data: task.id,
      onDragStarted: () {
        context.read<DragStateProvider>().startDrag(index);
      },
      onDragEnd: (data) {
        context.read<DragStateProvider>().endDrag();
      },
      feedback: buildTaskCard(task),
      childWhenDragging: const SizedBox(),
      child: buildDragTarget(context, task, index),
    );
  }

  Widget buildDragTarget(BuildContext context, Task task, int index) {
    if (task.isDone) {
      return GestureDetector(
        onTap: () {
          showTaskDetails(context, task);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: buildTaskContainer(context, task, []),
        ),
      );
    } else {
      return DragTarget(
        builder: (context, incoming, rejected) {
          return GestureDetector(
            onTap: () {
              showTaskDetails(context, task);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
              child: buildTaskContainer(context, task, incoming),
            ),
          );
        },
        onWillAccept: (data) => true,
        onAccept: (data) {
          final oldIndex = context.read<DragStateProvider>().originalIndex;
          final newIndex = index;
          context.read<TasksAPI>().updateTasksOrder(oldIndex, newIndex);
        },
        // Drag target callbacks...
      );
    }
  }

  Widget buildTaskContainer(
      BuildContext context, Task task, List<Object?> incoming) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: incoming.isNotEmpty ? Colors.blue[100] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          MSHCheckbox(
            size: 22,
            value: task.isDone,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: const Color.fromARGB(255, 0, 73, 133),
            ),
            style: MSHCheckboxStyle.fillScaleColor,
            onChanged: (selected) {
              context.read<TasksAPI>().updateTask(task.id, isDone: selected);
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.content,
              style: TextStyle(
                fontSize: 14,
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isDone ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const Spacer(),
          task.isDone
              ? const SizedBox()
              : GestureDetector(
                  child: Icon(Icons.push_pin_outlined, color: Colors.grey[600]),
                  onTap: () {
                    // context.read<TasksAPI>().pinTask(task.id);
                  },
                ),
        ],
      ),
    );
  }

  Widget buildTaskCard(Task task) {
    return Card(
      color: Colors.blue[100],
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Text(task.content),
      ),
    );
  }

  Widget doneTasksList(
      BuildContext context, List<dynamic> doneTasks, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: DragTarget(
            builder: (context, candidateData, rejectedData) {
              return ExpansionTile(
                maintainState: true,
                collapsedBackgroundColor: candidateData.isNotEmpty
                    ? Colors.blue[100]
                    : const Color(0xFFEEEDED),
                backgroundColor: candidateData.isNotEmpty
                    ? Colors.blue[100]
                    : const Color(0xFFEEEDED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                leading: SvgPicture.asset(
                  'assets/check-circle.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text('Done tasks (${doneTasks.length})'),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doneTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildTaskWidget(context, doneTasks[index], index);
                    },
                  ),
                ],
              );
            },
            onWillAccept: (data) => true,
            onAccept: (data) {
              context.read<TasksAPI>().updateTask(data as String, isDone: true);
            },
          ),
        ),
      ),
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
                    initialValue: task.content,
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
