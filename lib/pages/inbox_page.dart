import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/drag_provider.dart';
import '../services/task.dart';

class InboxPage extends StatelessWidget {
  // final List<Task> tasks;
  const InboxPage({super.key});

  // List<Task> get tasks => widget.tasks;
  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksAPI>().tasks;
    // final tasksProvider = Provider.of<TasksAPI>(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
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
                key: ValueKey(tasks[index]),
                data: tasks[index].id,
                feedback: Card(
                  color: Colors.blue[100],
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(tasks[index].content),
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
                  child: DragTarget(
                    builder: (context, incoming, rejected) {
                      // final isDragging =
                      //     Provider.of<DragStateProvider>(context).isDragging;
                      return Column(
                        children: [
                          Card(
                            color: incoming.isNotEmpty
                                ? Colors.blue[100]
                                : Colors.blue[50],
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              child: Text(tasks[index].content),
                              // child: ListTile(
                              //   title: Text(tasks[index].content),
                              //   // Add more details as needed
                              // ),
                            ),
                          ),
                          incoming.isNotEmpty ? const Divider(
                            color: Color.fromARGB(255, 0, 73, 133),
                            thickness: 2,
                          ): const SizedBox(),
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
                ),
              );
            },
          ),
        ),
      ],
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