import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

// import '../../models/tasks.dart';
import '../../models/entities.dart';
import '../../providers/drag_provider.dart';
import '../../providers/taskProvider.dart';
import '../../providers/task_provider.dart';
import 'horizontal_tags_view.dart';
import 'search_disposition_view.dart';

class TasksViewInboxPage extends StatelessWidget {
  const TasksViewInboxPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    List<Task> tasks = [];

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

    final notDoneTasks = tasks
        .where((task) => !task.isDone && task.list.target == null)
        .toList();
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
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
            child: buildTaskContainer(context, task, incoming),
          );
        },
        onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: (data) {
          final oldIndex = context.read<DragStateProvider>().originalIndex;
          final newIndex = index;
          context.read<TasksProvider>().updateTasksOrder(oldIndex, newIndex);
        },
        // Drag target callbacks...
      );
    }
  }

  //each task container
  Widget buildTaskContainer(
      BuildContext context, Task task, List<Object?> incoming) {
    return ListTile(
      // width: double.infinity,
      // decoration: BoxDecoration(
      //   color: incoming.isNotEmpty ? Colors.blue[100] : const Color(0xFFF7F7F7),
      //   borderRadius: BorderRadius.circular(12),
      // ),
      // padding: const EdgeInsets.all(16),
      // style: ListTileStyle.list,
      // selectedColor: Colors.blue,
      // tileColor: const Color(0xFFF7F7F7),
      leading: MSHCheckbox(
        size: 22,
        value: task.isDone,
        colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
          checkedColor: const Color.fromARGB(255, 0, 73, 133),
        ),
        style: MSHCheckboxStyle.fillScaleColor,
        onChanged: (selected) {
          context.read<TasksProvider>().updateTask(task.id, selected);
        },
      ),
      // const SizedBox(width: 10),
      title: Text(
        task.name,
        style: TextStyle(
          fontSize: 14,
          decoration:
              task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          color: task.isDone ? Colors.grey : Colors.black,
        ),
      ),
      //pin button
      // const Spacer(),
      trailing: PullDownButton(
        itemBuilder: (context) => [
          PullDownMenuItem(
            icon: Icons.edit,
            title: 'Edit',
            onTap: () {
              showTaskDetails(context, task);
            },
          ),
          const PullDownMenuDivider(),
          PullDownMenuItem(
            icon: Icons.delete,
            isDestructive: true,
            title: 'Delete',
            onTap: () {
              context.read<TasksProvider>().deleteTask(task.id);
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
      // task.isDone
      //     ? const SizedBox()
      //     : GestureDetector(
      //         child: Icon(Icons.push_pin_outlined, color: Colors.grey[600]),
      //         onTap: () {
      //           // context.read<TasksAPI>().pinTask(task.id);
      //         },
      //       ),
    );
  }

  Widget buildTaskCard(Task task) {
    return Card(
      color: Colors.blue[100],
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Text(task.name),
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
            onWillAcceptWithDetails: (data) => true,
            onAcceptWithDetails: (data) {
              final draggableData = data.data;
              context
                  .read<TasksProvider>()
                  .updateTask(draggableData as int, true);
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
