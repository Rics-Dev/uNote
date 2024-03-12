import 'package:flutter/material.dart';

import '../../pages/list_page.dart';
import 'pomodoro_main_page.dart';

Widget buildPomodoroBody(int bottomNavIndex) {
  switch (bottomNavIndex) {
    case 0:
      return const PomodoroMainPage();
    case 1:
      return const ListPage();
    default:
      return const PomodoroMainPage();
  }
}