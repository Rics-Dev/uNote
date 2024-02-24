import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../pages/inbox_page.dart';
import '../pages/list_page.dart';

Widget buildBody(int _bottomNavIndex, List<Task> tasks) {
  switch (_bottomNavIndex) {
    case 0:
      return InboxPage(tasks: tasks);
    case 1:
      return ListPage();
    default:
      return InboxPage(tasks: tasks);
  }
}
