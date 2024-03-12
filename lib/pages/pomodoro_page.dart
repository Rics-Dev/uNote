import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/drag_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/homePage/add_task_widgets/add_task_modal.dart';
import '../widgets/pomodoroPage/build_body_pomodoro_page.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  List<String> appBarTitles = [
    'Pomodoro',
    'Your lists',
  ];
  List<IconData> iconList = [
    Icons.inbox_rounded,
    Icons.format_list_bulleted_rounded,
  ];
  int _bottomNavIndex = 0;

  void removeTask(String taskId) async {
    try {
      await context.read<TasksAPI>().deleteTask(taskId: taskId);
      // showSuccessDelete();
    } on AppwriteException catch (e) {
      showAlert(title: 'Error', text: e.message.toString());
    }
  }

  Future<dynamic> _showAddTaskDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddTaskView(),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_bottomNavIndex]),
        actions: const <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.calendar_month_rounded),
          //   onPressed: () {
          //     _showCalendarView();
          //   },
          // ),
        ],
      ),
      floatingActionButton: keyboardIsOpened
          ? null
          : DragTarget(
              builder: (context, incoming, rejected) {
                return floatingActionButton(context, incoming.isNotEmpty);
              },
              onWillAcceptWithDetails: (data) => true,
              onAcceptWithDetails: (DragTargetDetails<Object> data) {
                final draggableData = data.data;
                removeTask(draggableData as String);
              }),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
          height: 65.0,
          icons: iconList,
          activeIndex: _bottomNavIndex,
          gapLocation: GapLocation.center,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          notchSmoothness: NotchSmoothness.softEdge,
          iconSize: 28,
          activeColor: const Color.fromARGB(255, 0, 73, 133),
          inactiveColor: Colors.grey,
          shadow: BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10),
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
          }
          //other params
          ),
      drawer: const AppDrawer(),
      body: buildPomodoroBody(_bottomNavIndex),
    );
  }

  FloatingActionButton floatingActionButton(
      BuildContext context, bool isNotEmpty) {
    final isDragging = Provider.of<DragStateProvider>(context).isDragging;
    return isDragging
        ? isNotEmpty
            ? FloatingActionButton.large(
                shape: const CircleBorder(),
                tooltip: 'add task',
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 50),
                onPressed: () {
                  _showAddTaskDialog(context);
                },
              )
            : FloatingActionButton(
                shape: const CircleBorder(),
                tooltip: 'add task',
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 38),
                onPressed: () {
                  _showAddTaskDialog(context);
                },
              )
        : FloatingActionButton(
            shape: const CircleBorder(),
            tooltip: 'add task',
            backgroundColor: const Color.fromARGB(255, 0, 73, 133),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 38),
            onPressed: () {
              _showAddTaskDialog(context);
            },
          );
  }

  showAlert({required String title, required String text}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }
}
