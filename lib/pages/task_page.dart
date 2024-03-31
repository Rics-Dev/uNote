import 'package:flutter/material.dart';
import '../widgets/taskPageWidgets/horizontal_priority_view.dart';
import '../widgets/inboxPage/tasks_view_inboxpage.dart';
import '../widgets/taskPageWidgets/task_tab_bar.dart';
import 'list_page.dart';

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
        const SizedBox(height: 10),
        const HorizontalPriorityView(),
        const SizedBox(height: 10),
        TaskTabBar(tabController: _tabController),
        const SizedBox(height: 20),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              TasksViewInboxPage(),
              ListPage(),
            ],
          ),
        ),
      ],
    );
  }
}


