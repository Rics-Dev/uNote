import 'package:flutter/material.dart';
import '../widgets/taskPageWidgets/horizontal_priority_view.dart';
import '../widgets/taskPageWidgets/task_inbox_page.dart';
import '../widgets/taskPageWidgets/task_tab_bar.dart';
import '../widgets/taskPageWidgets/task_list_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const HorizontalPriorityView(),
              const SizedBox(height: 10),
              TaskTabBar(tabController: _tabController),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              TaskInboxPage(),
              TaskListPage(),
            ],
          ),
        ),
      ],
    );
  }
}

        // SegmentedButton(
        //   segments: const [
        //     ButtonSegment(value: 0, label: Text('Inbox')),
        //     ButtonSegment(value: 1, label: Text('List')),
        //   ],
        //   selected: const {0},
        //   onSelectionChanged: (value) {
        //     if (value.contains(0)) {
        //       _tabController.animateTo(0);
        //     } else {
        //       _tabController.animateTo(1);
        //     }
        //   },
        // ),
