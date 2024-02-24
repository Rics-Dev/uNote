import 'package:appwrite/appwrite.dart';
import '../constants.dart' as constants;
import '../models/tasks.dart';
import 'auth.dart';

class TasksAPI {
  Client client = Client();
  late final Account account;
  late final Databases databases;

  TasksAPI(
      {String endpoint = constants.appwriteEndpoint,
      String projectId = constants.appwriteProjectId}) {
    init(endpoint, projectId);
  }

  void init(String endpoint, String projectId) {
    client =
        Client().setEndpoint(endpoint).setProject(projectId).setSelfSigned();

    account = Account(client);
    databases = Databases(client);
  }

  Future<List<Task>> getTasks({required AuthAPI auth}) async {
    final response = await databases.listDocuments(
      databaseId: constants.appwriteDatabaseId,
      collectionId: constants.appwriteTasksCollectionId,
      queries: [
        Query.equal("userID", [auth.userid])
      ],
    );
    return response.documents.map((e) => Task.fromMap(e.data)).toList();
  }

  Future<Task> createTask({required String task, required AuthAPI auth}) async {
    final document = await databases.createDocument(
        databaseId: constants.appwriteDatabaseId,
        collectionId: constants.appwriteTasksCollectionId,
        documentId: ID.unique(),
        data: {'content': task, 'userID': auth.userid});

    return Task.fromMap(document.data);
  }
}
