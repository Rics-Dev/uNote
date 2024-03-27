import 'package:flutter/material.dart';

import '../../pages/note_page.dart';
import '../../pages/task_page.dart';
import '../../pages/list_page.dart';

Widget buildBody(int bottomNavIndex) {
  switch (bottomNavIndex) {
    case 0:
      return const NotesPage();
    case 1:
      return const TasksPage();
    default:
      return const TasksPage();
  }
}
// , List<Task> tasks