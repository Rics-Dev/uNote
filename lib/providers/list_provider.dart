import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import '../constants.dart' as constants;
import 'auth_provider.dart';
import 'task_provider.dart';

class ListsAPI extends ChangeNotifier {
  Client client = Client();
  late final Account account;
  late final Databases databases;
  final AuthAPI auth = AuthAPI();
  final TasksAPI tasksAPI = TasksAPI();

  ListsAPI(
      {String endpoint = constants.appwriteEndpoint,
      String projectId = constants.appwriteProjectId}) {
    init(endpoint, projectId);
  }

  void init(String endpoint, String projectId) {
    client.setEndpoint(endpoint).setProject(projectId).setSelfSigned();
    account = Account(client);
    databases = Databases(client);
  }

  Future<void> createList(String listName) async {
    final response = await databases.createDocument(
      databaseId: constants.appwriteDatabaseId,
      collectionId: constants.appwriteListsCollectionId,
      documentId: ID.unique(),
      data: {'listname': listName},
    );
    print(response.data);
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
