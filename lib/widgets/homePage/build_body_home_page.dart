import 'package:flutter/material.dart';

import '../../pages/inbox_page.dart';
import '../../pages/list_page.dart';

Widget buildBody(int bottomNavIndex) {
  switch (bottomNavIndex) {
    case 0:
      return const InboxPage();
    case 1:
      return const ListPage();
    default:
      return const InboxPage();
  }
}
// , List<Task> tasks