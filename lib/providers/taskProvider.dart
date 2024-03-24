import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';
import '../objectbox.g.dart';

class TasksProvider extends ChangeNotifier {
  late final Box<Task> _taskBox;





  TasksProvider() {
    fetchTasks();
  }
  

  void fetchTasks() {
    _taskBox = objectbox.store.box<Task>();
  }

}
