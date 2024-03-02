import 'package:flutter/material.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/sort_filter_view.dart';
import '../widgets/inboxPage/tasks_view_inboxpage.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    

    return const Column(
      children: [
        SortAndFilterView(),
        SizedBox(height: 10),
        HorizontalTagsView(),
        TasksViewInboxPage(),
      ],
    );
  }
}
