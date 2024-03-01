import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';

import '../../providers/drag_provider.dart';
import '../../providers/task.dart';

class TasksViewInboxPage extends StatelessWidget {
  const TasksViewInboxPage({
    super.key,
    required this.filteredTasks,
  });

  final List filteredTasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                        showTaskDetails(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                        child: Container(
                          width: double.infinity,
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
                                colorConfig:
                                    MSHColorConfig.fromCheckedUncheckedDisabled(
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
                              Expanded(
                                child: Text(filteredTasks[index].content,
                                    style: TextStyle(
                                        fontSize: 14,
                                        decoration:
                                            filteredTasks[index].isDone == true
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        color:
                                            filteredTasks[index].isDone == true
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
                context.read<TasksAPI>().updateTasksOrder(oldIndex, newIndex);
              },
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> showTaskDetails(BuildContext context) {
    return showDialog(
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
