import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/drag_provider.dart';
import '../services/task.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

class InboxPage extends StatelessWidget {
  // final List<Task> tasks;
  InboxPage({super.key});

  bool isChecked = true;

  // List<Task> get tasks => widget.tasks;
  @override
  Widget build(BuildContext context) {
    final tasksAPI = context.watch<TasksAPI>();
    final tasks = tasksAPI.tasks;
    final tags = tasksAPI.tags;
    final selectedTags = tasksAPI.selectedTags;
    final filteredTasks = selectedTags.isEmpty || tasksAPI.filteredTags.isEmpty
        ? tasks
        : tasksAPI.filteredTasks.isNotEmpty
            ? tasksAPI.filteredTasks
            : [];

    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      context.read<TasksAPI>().toggleTagSelection(tag);
                      context.read<TasksAPI>().filterTasksByTags(selectedTags);
                    },
                    child: OutlinedButton.icon(
                      onPressed: () {
                        tasksAPI.toggleTagSelection(tag);
                        tasksAPI.filterTasksByTags(tasksAPI.selectedTags);
                      },
                      icon: Icon(
                        Icons.label_outline_rounded,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : const Color.fromARGB(255, 0, 73, 133),
                      ),
                      label: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color.fromARGB(255, 0, 73, 133),
                        ),
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4), // Adjust the padding as needed
                        ),
                        backgroundColor: isSelected
                            ? MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 0, 73, 133))
                            : MaterialStateProperty.all<Color>(
                                Colors.transparent),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // const SizedBox(height: 2),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              return LongPressDraggable(
                dragAnchorStrategy:
                    (Draggable<Object> _, BuildContext __, Offset ___) =>
                        const Offset(70, 70),
                // delay: const Duration(milliseconds: 100),
                onDragStarted: () {
                  context.read<DragStateProvider>().startDrag(index);
                },
                onDragEnd: (data) {
                  context.read<DragStateProvider>().endDrag();
                },
                key: ValueKey(filteredTasks[index]),
                data: filteredTasks[index].id,
                feedback: Card(
                  color: Colors.blue[100],
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(filteredTasks[index].content),
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: DragTarget(
                  builder: (context, incoming, rejected) {
                    // final isDragging =
                    //     Provider.of<DragStateProvider>(context).isDragging;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showTaskDetails(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                            child: AnimatedContainer(
                              width: double.infinity,
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: incoming.isNotEmpty
                                    ? Colors.blue[100]
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  MSHCheckbox(
                                    size: 22,
                                    value: filteredTasks[index].isDone,
                                    colorConfig: MSHColorConfig
                                        .fromCheckedUncheckedDisabled(
                                      checkedColor:
                                          const Color.fromARGB(255, 0, 73, 133),
                                    ),
                                    style: MSHCheckboxStyle.fillScaleColor,
                                    onChanged: (selected) {
                                      context.read<TasksAPI>().updateTask(
                                            filteredTasks[index].id,
                                            isDone: selected,
                                          );
                                    },
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                       context.read<TasksAPI>().updateTask(
                                            filteredTasks[index].id,
                                            isDone: !filteredTasks[index].isDone,
                                          );
                                    },
                                    child: Text(filteredTasks[index].content,
                                        style: TextStyle(
                                            fontSize: 14,
                                            decoration:
                                                filteredTasks[index].isDone ==
                                                        true
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            color: filteredTasks[index].isDone ==
                                                    true
                                                ? Colors.grey
                                                : Colors.black)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    final oldIndex =
                        context.read<DragStateProvider>().originalIndex;
                    final newIndex = index;
                    context
                        .read<TasksAPI>()
                        .updateTasksOrder(oldIndex, newIndex);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTaskDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            width: 300,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Task',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: 'Example Task',
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: 'This is an example task description.',
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Save changes
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Cancel editing
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
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

// onReorder: (oldIndex, newIndex) {
            //   if (oldIndex < newIndex) {
            //     newIndex -= 1;
            //   }
            //   final task = tasks.removeAt(oldIndex);
            //   tasks.insert(newIndex, task);
            // },