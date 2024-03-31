import 'package:flutter/material.dart';
import '../widgets/taskPageWidgets/horizontal_priority_view.dart';
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

class TaskTabBar extends StatelessWidget {
  const TaskTabBar({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 10), // changes position of shadow
          ),
        ],
        color: Colors.white,
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: false,
        tabs: const [
          Tab(
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'Inbox',
            icon: Icon(Icons.inbox_rounded),
          ),
          Tab(
            text: 'Lists',
            icon: Icon(Icons.format_list_bulleted_rounded),
            iconMargin: EdgeInsets.only(bottom: 2),
          )
        ],
      ),
    );
  }
}
