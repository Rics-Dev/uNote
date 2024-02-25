import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utask/services/task.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import '../models/tasks.dart';
import '../services/auth.dart';
import '../widgets/add_task_view.dart';
import '../widgets/calendar_view.dart';
import '../widgets/build_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _topModalData = "";
  late AuthAPI auth;
  final task = TasksAPI();
  TextEditingController taskController = TextEditingController();
  bool addTaskDialogOpened = false;
  int _bottomNavIndex = 0;
  List<IconData> iconList = [
    Icons.inbox_rounded,
    Icons.format_list_bulleted_rounded,
  ];
  List<String> appBarTitles = [
    'Your inbox',
    'Your lists',
  ];
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    getInitialTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthAPI>().status;
      if (auth == AuthStatus.uninitialized){
        await context.read<AuthAPI>().loadUser();
      }
      fetchTasks();
    });
  }

  void getInitialTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedTasks = prefs.getStringList('tasks');
    if (cachedTasks != null) {
      setState(() {
        tasks = cachedTasks
            .map((jsonString) => Task.fromJson(json.decode(jsonString)))
            .toList();
      });
    }
  }

  void fetchTasks() async {
    try {
      final auth = context.read<AuthAPI>();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await task.getTasks(auth: auth);
      setState(() {
        tasks = response;
      });
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
    } on AppwriteException catch (e) {
      showAlert(title: 'Error', text: e.message.toString());
    }
  }

  void addTask(String newTask) async {
    // Implement your add task logic here
    try {
      final auth = context.read<AuthAPI>();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await task.createTask(task: newTask, auth: auth);
      setState(() {
        tasks.add(response);
      });
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
    } on AppwriteException catch (e) {
      showAlert(title: 'Error', text: e.message.toString());
    }
  }

  Future<void> _showAddTaskDialog() async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) =>
          addTaskView(context, addTaskDialogOpened, taskController),
      isScrollControlled: true,
    ).whenComplete(() => setState(() {
          addTaskDialogOpened = !addTaskDialogOpened;
        }));

    if (result == true) {
      // If task was added successfully
      addTask(taskController.text);
      taskController.clear();
    }
  }

  Future<void> _showCalendarView() async {
    final value = await showTopModalSheet<String?>(
      context,
      const CalendarView(),
      backgroundColor: Colors.white,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(25),
      ),
    );

    if (value != null) setState(() => _topModalData = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_bottomNavIndex]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {_showCalendarView();},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        tooltip: 'add task',
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 38),
        // addTaskDialogOpened
        //     ? const Icon(Icons.close_rounded, color: Colors.white, size: 38)
        //     : const Icon(Icons.add_rounded, color: Colors.white, size: 38),
        onPressed: () {
          setState(() {
            addTaskDialogOpened = !addTaskDialogOpened;
          });
          if (addTaskDialogOpened) {
            taskController.text = ''; // Clear previous input
            // _showModalBottomSheet();
            _showAddTaskDialog();
          }
        },
        //params
      ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update UI based on drawer item selected
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update UI based on drawer item selected
              },
            ),
            // Add more ListTile widgets for additional items as needed
          ],
        ),
      ),
      body: buildBody(_bottomNavIndex, tasks),
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



      // if (task.auth.status == AuthStatus.uninitialized) {
      //   await task.auth.loadUser();
      // }




//old version
// void _showModalBottomSheet() {
  //   addTaskBox().whenComplete(() => setState(() {
  //         addTaskDialogOpened = !addTaskDialogOpened;
  //       }));
  // }

  // Future<dynamic> addTaskBox() {
    // return showModalBottomSheet(
    //   context: context,
    //   builder: (context) {
        // return AnimatedOpacity(
        //   opacity: addTaskDialogOpened ? 1.0 : 0.0,
        //   duration: const Duration(milliseconds: 5000),
        //   child: AnimatedContainer(
        //     duration: const Duration(milliseconds: 5000),
        //     height: addTaskDialogOpened
        //         ? MediaQuery.of(context).size.height * 0.62
        //         : 0.0,
        //     child: Wrap(
        //       // Use Wrap widget to center the content vertically
        //       children: [
        //         Center(
        //           // Center the content vertically
        //           child: Padding(
        //             padding: MediaQuery.of(context)
        //                 .viewInsets, // Adjust for keyboard
        //             child: Container(
        //               padding: const EdgeInsets.all(20.0),
        //               height: MediaQuery.of(context).size.height *
        //                   0.21, // 30% of screen height
        //               child: Column(
        //                 children: [
        //                   TextField(
        //                     controller: taskController,
        //                     autofocus:
        //                         true, // Automatically focus the input field
        //                     decoration: const InputDecoration(
        //                       labelText: 'Enter Task',
        //                       border: OutlineInputBorder(),
        //                     ),
        //                     keyboardType: TextInputType
        //                         .text, // Set appropriate keyboard type
        //                     textInputAction: TextInputAction
        //                         .done, // Dismiss keyboard on Done
        //                     onSubmitted: (_) {
        //                       setState(() {
        //                         addTaskDialogOpened = !addTaskDialogOpened;
        //                       });
        //                       // Handle task submission, e.g.,
        //                       _addTask(taskController.text);
        //                       Navigator.pop(context); // Close bottom sheet
        //                     },
        //                   ),
        //                   const SizedBox(height: 10.0),
        //                   // Row(
        //                   //   mainAxisAlignment: MainAxisAlignment.end,
        //                   //   children: [
        //                   //     TextButton(
        //                   //       onPressed: () {
        //                   //         Navigator.pop(context); // Close bottom sheet
        //                   //       },
        //                   //       child: const Text('Cancel'),
        //                   //     ),
        //                   //     const SizedBox(width: 10.0),
        //                   //     ElevatedButton(
        //                   //       onPressed: () {
        //                   //         // Handle task submission, e.g.,
        //                   //         _addTask(taskController.text);
        //                   //         Navigator.pop(context); // Close bottom sheet
        //                   //       },
        //                   //       child: const Text('Submit'),
        //                   //     ),
        //                   //   ],
        //                   // ),
        //                   Center(
        //                     child: ElevatedButton(
        //                       onPressed: () {
        //                         setState(() {
        //                           addTaskDialogOpened = !addTaskDialogOpened;
        //                         });
        //                         // Handle task submission, e.g.,
        //                         _addTask(taskController.text);
        //                         Navigator.pop(context); // Close bottom sheet
        //                       },
        //                       style: ElevatedButton.styleFrom(
        //                         backgroundColor:
        //                             const Color.fromARGB(255, 0, 73, 133),
        //                         shape: const CircleBorder(),
        //                         padding: const EdgeInsets.all(10),
        //                       ),
        //                       child: const Icon(Icons.check_rounded,
        //                           color: Colors.white, size: 38),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // );
    //   },
    //   isScrollControlled: true, // Ensure content stays above keyboard
    // );
  // }