import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/taskProvider.dart';
import '../widgets/inboxPage/horizontal_priority_view.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/search_disposition_view.dart';
import '../widgets/inboxPage/tasks_view_inboxpage.dart';
import 'list_page.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final taskLists = tasksProvider.taskLists;
    return Column(
      children: [
        // SortAndFilterView(),
        const SizedBox(height: 10),
        // HorizontalTagsView(),
        const HorizontalPriorityView(),
        const SizedBox(height: 10),
        TabBar(
          isScrollable: true,
          tabs: [
            const Tab(text: 'Inbox'),
            ...taskLists.map((taskList) => Tab(text: taskList.name)).toList(),
            const Tab(
              icon: Icon(
                Icons.add,
              ),
            ),
          ],
        ),
        // SizedBox(height: 20),
        // Expanded(
        //   child: TabBarView(
        //     children: [
        //       TasksViewInboxPage(),
        //       ListPage(),
        //     ],
        //   ),
        // ),
        const TasksViewInboxPage(),
      ],
    );
  }
}
