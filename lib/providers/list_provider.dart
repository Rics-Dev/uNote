import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart' as constants;
import '../models/lists.dart';
import '../models/tasks.dart';
import 'auth_provider.dart';
import 'task_provider.dart';

class ListsAPI extends ChangeNotifier {
  var uuid =const Uuid();
  late SharedPreferences prefs;
  Client client = Client();
  late final Account account;
  late final Databases databases;
  final AuthAPI auth = AuthAPI();
  final TasksAPI tasksAPI = TasksAPI();
  List<ListItem> _lists = [];

  List<ListItem> get lists => _lists;

  ListsAPI(
      {String endpoint = constants.appwriteEndpoint,
      String projectId = constants.appwriteProjectId}) {
    init(endpoint, projectId);
  }

  void init(String endpoint, String projectId) {
    client.setEndpoint(endpoint).setProject(projectId).setSelfSigned();
    account = Account(client);
    databases = Databases(client);
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    try {
      prefs = await SharedPreferences.getInstance();
      await fetchLocalLists();
      await fetchServerLists();
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

  Future<void> fetchServerLists() async {
    final serverLists = await databases.listDocuments(
      databaseId: constants.appwriteDatabaseId,
      collectionId: constants.appwriteListsCollectionId,
    );
    _lists =
        serverLists.documents.map((e) => ListItem.fromMap(e.data)).toList();
    notifyListeners();

    await prefs.setStringList('lists', lists.map((list) => json.encode(list.toJson())).toList());
  }

  Future<void> createList(String listName) async {
    final listId = uuid.v4();
    await createLocalList(listName: listName,listId:  listId);
    await createServerList(listName: listName,listId:  listId);
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

  Future<void> createServerList({required String listName, required String listId}) async {
    await databases.createDocument(
      databaseId: constants.appwriteDatabaseId,
      collectionId: constants.appwriteListsCollectionId,
      documentId: listId,
      data: {'listname': listName},
    );
    notifyListeners();
  }

  Future<int> verifyExistingList(String listName) async {
    final existingListDocument = await databases.listDocuments(
      databaseId: constants.appwriteDatabaseId,
      collectionId: constants.appwriteListsCollectionId,
      queries: [
        Query.equal("listname", [listName])
      ],
    );
    return existingListDocument.total;
  }
}
