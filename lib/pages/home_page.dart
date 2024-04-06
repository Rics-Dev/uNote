import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:utask/theme/theme.dart';
import '../providers/note_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/notePageWidgets/add_note_modal.dart';
import '../widgets/taskPageWidgets/add_task_modal.dart';
import '../widgets/homePageWidgets/calendar_view.dart';
import '../widgets/homePageWidgets/sort_view.dart';
import 'note_page.dart';
import 'task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool deleteFloatingActionButton = false;

  bool addTaskDialogOpened = false;
  int _bottomNavIndex = 0;

  List<IconData> iconList = [
    Icons.sticky_note_2_rounded,
    Icons.done_all_rounded,
  ];
  List<String> appBarTitles = [
    'Your Notes',
    'Your Tasks',
  ];

  Future<dynamic> _showAddTaskDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddTaskView(),
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
    );
  }

  Future<dynamic> _showAddNoteDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AddNoteView(),
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

  Future<dynamic> _showSortView(BuildContext context) {
    return showTopModalSheet(
      transitionDuration: const Duration(milliseconds: 500),
      context,
      const SortView(),
      backgroundColor: Colors.white,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeData;
    final notesProvider = context.watch<NotesProvider>();
    final noteBooks = notesProvider.noteBooks;
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;

    if (_bottomNavIndex == 0) {
      if (notesProvider.selectedNoteBook > 1 &&
          notesProvider.selectedNoteBook < noteBooks.length + 2) {
        appBarTitles[_bottomNavIndex] =
            noteBooks[notesProvider.selectedNoteBook - 2].name;
      } else if (notesProvider.selectedNoteBook == 0) {
        appBarTitles[_bottomNavIndex] = 'Vault';
      } else {
        appBarTitles[_bottomNavIndex] = 'Your Notes';
      }
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: themeMode.brightness == Brightness.dark
              ? const Icon(Icons.wb_sunny_outlined)
              : const Icon(Icons.nightlight_outlined),
          onPressed: () {
            context.read<ThemeProvider>().toggleTheme();
          },
        ),
        title: Text(appBarTitles[_bottomNavIndex]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
            ),
            onPressed: () {
              _showSortView(context);
            },
          ),
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
              },
            ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        splashRadius: 0,
        height: 65.0,
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        notchSmoothness: NotchSmoothness.softEdge,
        iconSize: 28,
        activeColor: const Color.fromARGB(255, 0, 73, 133),
        // inactiveColor: Colors.white,
        shadow: BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10),
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
      body: buildBody(_bottomNavIndex),
    );
  }

  Widget floatingActionButton(BuildContext context, bool isNotEmpty) {
    final isDragging = Provider.of<TasksProvider>(context).isDragging;
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
                    if (_bottomNavIndex == 0) {
                      _showAddNoteDialog(context);
                    } else {
                      _showAddTaskDialog(context);
                    }
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
                    if (_bottomNavIndex == 0) {
                      _showAddNoteDialog(context);
                    } else {
                      _showAddTaskDialog(context);
                    }
                  },
                ),
              )
        : FloatingActionButton(
            shape: const CircleBorder(),
            tooltip: _bottomNavIndex == 0 ? 'Add Note' : 'Add Task',
            backgroundColor: const Color.fromARGB(255, 0, 73, 133),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 38),
            onPressed: () {
              if (_bottomNavIndex == 0) {
                _showAddNoteDialog(context);
              } else {
                _showAddTaskDialog(context);
              }
            },
          );
  }

  Widget buildBody(int bottomNavIndex) {
    switch (bottomNavIndex) {
      case 0:
        return const NotesPage();
      case 1:
        return const TasksPage();
      default:
        return const NotesPage();
    }
  }
}
