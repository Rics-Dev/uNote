import 'package:flutter/material.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/search_disposition_view.dart';
import '../widgets/inboxPage/tasks_view_inboxpage.dart';
import 'list_page.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SortAndFilterView(),
        SizedBox(height: 10),
        HorizontalTagsView(),
        // TabBar(
        //   tabs: <Widget>[
        //     Tab(text: 'Inbox'),
        //     Tab(text: 'Lists'),
        //   ],
        // ),
        // SizedBox(height: 20),
        // Expanded(
        //   child: TabBarView(
        //     children: [
        //       TasksViewInboxPage(),
        //       ListPage(),
        //     ],
        //   ),
        // ),
        TasksViewInboxPage(),
      ],
    );
  }
}
