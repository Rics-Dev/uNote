import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:utask/providers/task_provider.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import '../main.dart';
import '../providers/drag_provider.dart';
import '../providers/taskProvider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/homePage/add_task_widgets/add_task_modal.dart';
import '../widgets/homePage/build_body_home_page.dart';
import '../widgets/homePage/calendar_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool deleteFloatingActionButton = false;

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

  Future<dynamic> _showAddTaskDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddTaskView(),
      isScrollControlled: true,
    );
  }

  Future<dynamic> _showCalendarView() {
    return showTopModalSheet<String?>(
      transitionDuration: const Duration(milliseconds: 500),
      context,
      const CalendarView(),
      backgroundColor: Colors.white,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.calendar_month_rounded),
        //   onPressed: () {
        //     _showCalendarView();
        //   },
        // ),
        title: Text(appBarTitles[_bottomNavIndex]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {
              _showCalendarView();
            },
          ),
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
                context.read<TasksProvider>().deleteTask(draggableData as int);
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
      // drawer: const AppDrawer(),
      body: buildBody(_bottomNavIndex),
    );
  }

  Widget floatingActionButton(BuildContext context, bool isNotEmpty) {
    final isDragging = Provider.of<DragStateProvider>(context).isDragging;
    return isDragging
        ? isNotEmpty
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut, // Animation curve
                width: 80, // Animated width
                height: 80,
                child: FloatingActionButton.large(
                  shape: const CircleBorder(),
                  tooltip: 'remove task',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.white, size: 38),
                  onPressed: () {
                    _showAddTaskDialog(context);
                  },
                ),
              )
            : AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut, // Animation curve
                width: 60, // Animated width
                height: 60,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  tooltip: 'remove task',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.white, size: 38),
                  onPressed: () {
                    _showAddTaskDialog(context);
                  },
                ),
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
