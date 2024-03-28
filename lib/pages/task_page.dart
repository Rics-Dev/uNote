import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/taskProvider.dart';
import '../widgets/inboxPage/horizontal_priority_view.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/search_disposition_view.dart';
import '../widgets/inboxPage/tasks_view_inboxpage.dart';
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
    final tasksProvider = context.watch<TasksProvider>();
    final taskLists = tasksProvider.taskLists;
    return Column(
      children: [
        const SizedBox(height: 10),
        const HorizontalPriorityView(),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: false,
            tabs: const [Tab(text: 'Inbox'), Tab(text: 'Lists')],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // ListPage(),
              TasksViewInboxPage(),
              ListPage(),
            ],
          ),
        ),
        // TasksViewInboxPage(),
      ],
    );
  }
}
