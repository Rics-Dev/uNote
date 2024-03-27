import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/taskProvider.dart';
import '../widgets/inboxPage/horizontal_priority_view.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/search_disposition_view.dart';
import '../widgets/inboxPage/tasks_view_inboxpage.dart';
import 'list_page.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final taskLists = tasksProvider.taskLists;
    return const Column(
      children: [
        // SortAndFilterView(),
        SizedBox(height: 10),
        // HorizontalTagsView(),
        HorizontalPriorityView(),
        SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: false,
            tabs: [
              Tab(text: 'Inbox'),
              // ...taskLists.map((taskList) => Tab(text: taskList.name)).toList(),
              // const Tab(
              //   icon: Icon(
              //     Icons.add,
              //   ),
              // ),
              Tab(text: 'Lists')
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: TabBarView(
            children: [
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
