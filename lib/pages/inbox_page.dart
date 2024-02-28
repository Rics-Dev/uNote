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
                child: DragTarget(
                  builder: (context, incoming, rejected) {
                    // final isDragging =
                    //     Provider.of<DragStateProvider>(context).isDragging;
                    return Column(
                      children: [
                        Padding(
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
                            child: Text(tasks[index].content),
                          ),
                        ),
                        // incoming.isNotEmpty
                        //     ? AnimatedContainer(
                        //       duration: const Duration(milliseconds: 300),
                        //       child: const Divider(
                        //           color: Color.fromARGB(255, 0, 73, 133),
                        //           indent: 20,
                        //           endIndent: 20,
                        //           thickness: 2,
                        //         ),
                        //     )
                        //     : AnimatedContainer(duration: const Duration(milliseconds: 300),child: const SizedBox()),
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
}



// onReorder: (oldIndex, newIndex) {
            //   if (oldIndex < newIndex) {
            //     newIndex -= 1;
            //   }
            //   final task = tasks.removeAt(oldIndex);
            //   tasks.insert(newIndex, task);
            // },