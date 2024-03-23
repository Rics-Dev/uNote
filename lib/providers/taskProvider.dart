

// import 'package:flutter/material.dart';
// import 'package:utask/database/database.dart';

// class TasksProvider extends ChangeNotifier{

//   final database = MyDatabase();

//   final List<Task> _tasks = [];
//   List<Task> get tasks => _tasks;


//   Future<void> addTask(TasksCompanion task) async {
//     await database.into(database.tasks).insert(task);
//     notifyListeners();
//   }


//   fetchTasks() async {
//     final tasks = await database.select(database.tasks).get();
//     _tasks.clear();
//     _tasks.addAll(tasks);
//     notifyListeners();
//   }

  
// }