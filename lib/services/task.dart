import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart' as constants;
import '../models/tasks.dart';
import 'auth.dart';

class TasksAPI extends ChangeNotifier {
  Client client = Client();
  late final Account account;
  late final Databases databases;
  final AuthAPI auth = AuthAPI();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TasksAPI(
      {String endpoint = constants.appwriteEndpoint,
      String projectId = constants.appwriteProjectId}) {
    init(endpoint, projectId);
    fetchTasks();
  }

  void init(String endpoint, String projectId) {
    client =
        Client().setEndpoint(endpoint).setProject(projectId).setSelfSigned();

    account = Account(client);
    databases = Databases(client);
  }

  void fetchTasks() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final cachedTasks = prefs.getStringList('tasks');
      if (cachedTasks != null) {
        _tasks = cachedTasks
            .map((jsonString) => Task.fromJson(json.decode(jsonString)))
            .toList();
        notifyListeners();
      }

      if (auth.status == AuthStatus.uninitialized) {
        await auth.loadUser();
      }
      final response = await databases.listDocuments(
        databaseId: constants.appwriteDatabaseId,
        collectionId: constants.appwriteTasksCollectionId,
        queries: [
          Query.equal("userID", [auth.userid])
        ],
      );
      final results =
          response.documents.map((e) => Task.fromMap(e.data)).toList();
      _tasks = results;
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
      notifyListeners();
    } finally {
      notifyListeners();
    }
  }

  Future<void> createTask({required String task}) async {
    try {
      final document = await databases.createDocument(
          databaseId: constants.appwriteDatabaseId,
          collectionId: constants.appwriteTasksCollectionId,
          documentId: ID.unique(),
          data: {'content': task, 'userID': auth.userid});

      final newtask = Task.fromMap(document.data);
      _tasks.add(newtask);
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
    } finally {
      notifyListeners();
    }
  }
}



  // Future<void> getTasks({required AuthAPI auth}) async {
  //   try {
  //     final response = await databases.listDocuments(
  //       databaseId: constants.appwriteDatabaseId,
  //       collectionId: constants.appwriteTasksCollectionId,
  //       queries: [
  //         Query.equal("userID", [auth.userid])
  //       ],
  //     );
  //     final results =
  //         response.documents.map((e) => Task.fromMap(e.data)).toList();
  //     tasks = results;
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setStringList(
  //         'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
  //   } finally {
  //     notifyListeners();
  //   }
  // }