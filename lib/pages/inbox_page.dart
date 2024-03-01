import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import '../providers/task.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/sort_filter_view.dart';
import '../widgets/inboxPage/tasks_view_inboxpage.dart';

class InboxPage extends StatelessWidget {
  // final List<Task> tasks;
  InboxPage({super.key});

  bool isChecked = true;
  @override
  Widget build(BuildContext context) {
    final tasksAPI = context.watch<TasksAPI>();
    final tasks = tasksAPI.tasks;
    final tags = tasksAPI.tags;
    final selectedTags = tasksAPI.selectedTags;
    final filteredTasks = selectedTags.isEmpty || tasksAPI.filteredTags.isEmpty
        ? tasks
        : tasksAPI.filteredTasks.isNotEmpty
            ? tasksAPI.filteredTasks
            : [];

    return Column(
      children: [
        SortAndFilterView(),
        const SizedBox(height: 10),
        HorizontalTagsView(
            selectedTags: selectedTags,
            tags: tags,
            context: context,
            tasksAPI: tasksAPI),
        TasksViewInboxPage(filteredTasks: filteredTasks),
      ],
    );
  }
}


