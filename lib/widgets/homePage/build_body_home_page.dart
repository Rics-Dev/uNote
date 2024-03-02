import 'package:flutter/material.dart';

import '../../pages/inbox_page.dart';
import '../../pages/list_page.dart';
Widget buildBody(int _bottomNavIndex, searchBar) {
  switch (_bottomNavIndex) {
    case 0:
      return  InboxPage();
    case 1:
      return ListPage();
    default:
      return  InboxPage();
  }
}
// , List<Task> tasks