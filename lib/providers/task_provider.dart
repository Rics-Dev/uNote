import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
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
  List<String> _tags = [];
  List<String> _filteredTags = [];
  List<Task> _filteredTasks = [];
  final List<String> _selectedTags = [];
  bool _sortByCreationDate = true;
  bool _sortByEditionDate = false;
  bool _oldToNew = true;

  List<Task> get tasks => _tasks;
  List<String> get tags => _tags;
  List<String> get filteredTags => _filteredTags;
  List<Task> get filteredTasks => _filteredTasks;
  List<String> get selectedTags => _selectedTags;
  bool get sortByCreationDate => _sortByCreationDate;
  bool get sortByEditionDate => _sortByEditionDate;
  bool get oldToNew => _oldToNew;

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

  //for fetching tasks
  void fetchTasks() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.remove('tasks');
      final cachedTasks = prefs.getStringList('tasks');
      final cachedTags = prefs.getStringList('tags');
      if (cachedTasks != null) {
        _tasks = cachedTasks
            .map((jsonString) => Task.fromJson(json.decode(jsonString)))
            .toList();
        _filteredTasks = _tasks;
        notifyListeners();
      }
      if (cachedTags != null) {
        _tags = cachedTags;
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
      final response2 = await databases.listDocuments(
        databaseId: constants.appwriteDatabaseId,
        collectionId: constants.appwriteTagsCollectionId,
      );
      final results2 =
          response2.documents.map((e) => e.data['tagname'].toString()).toList();
      _tags = results2;

      prefs.setStringList('tags', tags);

      _filteredTags = _tags;
      _filteredTasks = _tasks;
      notifyListeners();
    } finally {
      notifyListeners();
    }
  }

  //to create tasks and tags
  Future<void> createTask(
      {required String task, required List<String> tags}) async {
    final List<Map<String, dynamic>> tagList =
        tags.map((tag) => {'tagname': tag}).toList();
    List<String> tagIds = [];
    final newTask = Task.fromMap({
      'content': task,
      'userID': auth.userid,
      'tags': tagList,
      'favorite': false,
      'isDone': false,
      '\u0024createdAt': DateTime.now().toIso8601String(),
      '\u0024updatedAt': DateTime.now().toIso8601String(),
    });
    _tasks.add(newTask);
    final newTags = tags.map((tag) => tag).toList();
    for (var tag in newTags) {
      if (!_tags.contains(tag)) {
        _tags.add(tag);
      }
    }
    notifyListeners();
    try {
      //creating tags when creating a task
      for (var tag in tags) {
        // Check if the tag already exists
        final existingTagDocument = await databases.listDocuments(
          databaseId: constants.appwriteDatabaseId,
          collectionId: constants.appwriteTagsCollectionId,
          queries: [
            Query.equal("tagname", [tag])
          ],
        );
        if (existingTagDocument.total != 0) {
          tagIds.addAll(
              existingTagDocument.documents.map((doc) => doc.data['\u0024id']));
        } else {
          // Create the tag if it doesn't exist
          final tagDocument = await databases.createDocument(
            databaseId: constants.appwriteDatabaseId,
            collectionId: constants.appwriteTagsCollectionId,
            documentId: tag,
            data: {'tagname': tag},
          );
          tagIds.add(tagDocument.data['\u0024id']);
        }
      }
      final document = await databases.createDocument(
          databaseId: constants.appwriteDatabaseId,
          collectionId: constants.appwriteTasksCollectionId,
          documentId: ID.unique(),
          data: {'content': task, 'userID': auth.userid, 'tags': tagIds});

      final serverTask = Task.fromMap(document.data);
      _tasks.removeLast();
      _tasks.add(serverTask);
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
      prefs.setStringList('tags', _tags);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating task: $e');
      }
      _tasks.removeLast();
      notifyListeners();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  //to delete tasks
  Future<void> deleteTask({required String taskId}) async {
    Task? removedTask;
    _tasks.removeWhere((task) {
      if (task.id == taskId) {
        removedTask = task;
        return true;
      }
      return false;
    });
    _filteredTasks.removeWhere((task) => task.id == taskId);
    notifyListeners();

    //after removing task remove unused tags
    removeUnusedTag(removedTask);

    try {
      await databases.deleteDocument(
          databaseId: constants.appwriteDatabaseId,
          collectionId: constants.appwriteTasksCollectionId,
          documentId: taskId);
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());

      prefs.setStringList('tags', _tags);
    } catch (e) {
      if (removedTask != null) {
        _tasks.add(removedTask!);
        notifyListeners();
      }
    } finally {
      notifyListeners();
    }
  }

  void removeUnusedTag(Task? removedTask) async {
    if (removedTask != null && removedTask.tags.isNotEmpty) {
      final List<String> tagsToRemove = removedTask.tags
          .toList(); // Copy the list to avoid concurrent modification issues
      for (final tagToRemove in tagsToRemove) {
        bool isTagUsed = false;
        for (final task in _tasks) {
          if (task.id != removedTask.id && task.tags.contains(tagToRemove)) {
            // Check if the tag is used by any other task except the removed task
            isTagUsed = true;
            break;
          }
        }

        // If the tag is not used by any other task, remove it
        if (!isTagUsed) {
          tags.remove(tagToRemove);
          clearSelectedTags();
          notifyListeners();
          try {
            await databases.deleteDocument(
              databaseId: constants.appwriteDatabaseId,
              collectionId: constants.appwriteTagsCollectionId,
              documentId: tagToRemove,
            );
          } catch (e) {
            if (kDebugMode) {
              print('Error removing tag: $e');
            }
          }
        }
      }
    }
  }

  //to update tasks
  void updateTask(String id, {required bool isDone}) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    final task = _tasks.firstWhere((task) => task.id == id);
    task.isDone = isDone;

    // if (isDone) {
    //   _tasks.removeAt(taskIndex);
    //   _tasks.add(task);
    // }

    notifyListeners();
    try {
      await databases.updateDocument(
        databaseId: constants.appwriteDatabaseId,
        collectionId: constants.appwriteTasksCollectionId,
        documentId: id,
        data: {'isDone': isDone},
      );
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
      // If an error occurs, revert the task's state
      task.isDone = !isDone;
      if (isDone) {
        _tasks.removeLast();
        _tasks.insert(taskIndex, task);
      }
      notifyListeners();
      rethrow;
    }
  }

  //to update tasks order only locally
  void updateTasksOrder(int oldIndex, int newIndex) {
    // Perform reordering logic here
    // if (oldIndex < newIndex) {
    //     newIndex -= 1;
    //   }
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
    notifyListeners(); // Notify listeners for rebuild
  }

  //to search for tags when creating them
  void setFilteredTags(List<String> suggestions) {
    _filteredTags = suggestions;
    notifyListeners();
  }

  //when selecting tags in the inbox page to filter
  void toggleTagSelection(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearSelectedTags() {
    _selectedTags.clear();
    _filteredTasks = tasks;
    notifyListeners();
  }

  //to filter tasks by tags
  void filterTasksByTags(List tags) {
    _filteredTasks = _tasks.where((task) {
      return tags.every((tag) => task.tags.contains(tag));
    }).toList();
    notifyListeners();
  }

  void toggleSortByCreationDate() {
    if (_sortByEditionDate == true) {
      _sortByCreationDate = true;
      _sortByEditionDate = false;
    }
    toggleNewToOld();
    notifyListeners();
  }

  void toggleSortByEditionDate() {
    if (_sortByCreationDate == true) {
      _sortByCreationDate = false;
      _sortByEditionDate = true;
    }
    toggleNewToOld();
    notifyListeners();
  }

  void toggleNewToOld() {
    _oldToNew = !_oldToNew;

    filteredTasks.sort((a, b) {
      if (_sortByCreationDate) {
        if (_oldToNew) {
          return a.createdAt.compareTo(b.createdAt);
        } else {
          return b.createdAt.compareTo(a.createdAt);
        }
      } else if (_sortByEditionDate) {
        if (_oldToNew) {
          return a.updatedAt.compareTo(b.updatedAt);
        } else {
          return b.updatedAt.compareTo(a.updatedAt);
        }
      }
      return 0;
    });

    notifyListeners();
  }
}
