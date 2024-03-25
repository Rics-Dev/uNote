import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart' as constants;
import '../models/lists.dart';
import 'task_provider.dart';

class ListsAPI extends ChangeNotifier {
  var uuid =const Uuid();
  late SharedPreferences prefs;
  final TasksAPI tasksAPI = TasksAPI();
  List<ListItem> _lists = [];

  List<ListItem> get lists => _lists;

  ListsAPI(
      {String endpoint = constants.appwriteEndpoint,
      String projectId = constants.appwriteProjectId}) {
    init(endpoint, projectId);
  }

  void init(String endpoint, String projectId) {
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    try {
      prefs = await SharedPreferences.getInstance();
      await fetchLocalLists();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> fetchLocalLists() async {
    final localLists = prefs.getStringList('lists');
    if (localLists != null) {
      _lists = localLists
          .map((jsonString) => ListItem.fromJson(json.decode(jsonString)))
          .toList();
    }
    notifyListeners();
  }


  Future<void> createList(String listName) async {
    final listId = uuid.v4();
    await createLocalList(listName: listName,listId:  listId);
    
  }

  Future<void> createLocalList({required String listName, required String listId} ) async {
    final newList = ListItem(
      listName: listName,
      id: listId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _lists.add(newList);
    await prefs.setStringList('lists', lists.map((list) => json.encode(list.toJson())).toList());
    notifyListeners();
  }


  Future<int> verifyExistingList(String listName) async {

      return await verifyLocalExistingList(listName);
  }


  Future<int> verifyLocalExistingList(String listName) async {
    final existingList = _lists.where((list) => list.listName == listName);
    return existingList.length;
  }

}
