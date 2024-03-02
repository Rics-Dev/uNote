import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart' as constants;
import '../models/tasks.dart';
import 'auth.dart';

enum SortCriteria {
  creationDate,
  editionDate,
  nameAZ,
  nameZA,
}

class TasksAPI extends ChangeNotifier {
  Client client = Client();
  late final Account account;
  late final Databases databases;
  final AuthAPI auth = AuthAPI();
  List<Task> _tasks = [];
  List<String> _tags = [];
  List<String> _searchedTags = [];
  List<Task> _filteredTasks = [];
  List<Task> _searchedTasks = [];
  final List<String> _selectedTags = [];
  final List<String> _temporarilyAddedTags = [];
  bool _oldToNew = true;

  SortCriteria _sortCriteria = SortCriteria.creationDate;

  List<Task> get tasks => _tasks;
  List<String> get tags => _tags;
  List<String> get searchedTags => _searchedTags;
  List<Task> get filteredTasks => _filteredTasks;
  List<Task> get searchedTasks => _searchedTasks;
  List<String> get selectedTags => _selectedTags;
  List<String> get temporarilyAddedTags => _temporarilyAddedTags;
  bool get oldToNew => _oldToNew;
  SortCriteria get sortCriteria => _sortCriteria;

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
        // _filteredTasks = _tasks;
        notifyListeners();
      }
      if (cachedTags != null) {
        _tags = cachedTags;
        notifyListeners();
      }

      if (auth.status == AuthStatus.uninitialized) {
        await auth.loadUser();
      }
      final serverTasks = await databases.listDocuments(
        databaseId: constants.appwriteDatabaseId,
        collectionId: constants.appwriteTasksCollectionId,
        queries: [
          Query.equal("userID", [auth.userid])
        ],
      );
      final serverTasksResults =
          serverTasks.documents.map((e) => Task.fromMap(e.data)).toList();
      _tasks = serverTasksResults;
      prefs.setStringList(
          'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
      notifyListeners();
      final serverTags = await databases.listDocuments(
        databaseId: constants.appwriteDatabaseId,
        collectionId: constants.appwriteTagsCollectionId,
      );
      final serverTagsResults = serverTags.documents
          .map((e) => e.data['tagname'].toString())
          .toList();
      _tags = serverTagsResults;

      prefs.setStringList('tags', tags);

      _searchedTags = _tags;
      // _filteredTasks = _tasks;
      notifyListeners();
    } finally {
      notifyListeners();
    }
  }

  //to create tasks and tags
  Future<void> createTask({
    required String task,
    required List<String> tags,
  }) async {
    final List<Map<String, dynamic>> tagList =
        tags.map((tag) => {'tagname': tag}).toList();
    List<String> tagIds = [];
    final newTask = Task.fromMap({
      'content': task,
      'userID': auth.userid,
      'tags': tagList,
      'isDone': false,
      '\u0024createdAt': DateTime.now().toIso8601String(),
      '\u0024updatedAt': DateTime.now().toIso8601String(),
    });
    _tasks.add(newTask);

    if (tags.isNotEmpty && _selectedTags.any((tag) => tags.contains(tag))) {
      _filteredTasks.add(newTask);
    }

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
    } finally {
      //remove temporarilly added tags after creating a task
      _temporarilyAddedTags.clear();
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

  void deleteTag(String tag) async {
    _tags.remove(tag);
    for (var task in _tasks) {
      if (task.tags.contains(tag)) {
        // If the task contains the tag, remove it
        task.tags.remove(tag);
      }
    }
    notifyListeners();
    try {
      await databases.deleteDocument(
        databaseId: constants.appwriteDatabaseId,
        collectionId: constants.appwriteTagsCollectionId,
        documentId: tag,
      );
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('tags', _tags);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting tag: $e');
      }
    }
  }

  //to update tasks (for now only when it's done)
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
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
    notifyListeners(); // Notify listeners for rebuild
  }

  //to search for tags when creating them
  void setSearchedTags(List<String> suggestions) {
    _searchedTags = suggestions;
    notifyListeners();
  }

  void setSearchedTasks(List<Task> searchedTasks) {
    if (searchedTasks.isEmpty) {
      _searchedTasks.clear();
    }
    _searchedTasks = searchedTasks;
    notifyListeners();
  }

  //when selecting tags in the inbox page to filter
  void toggleTagSelection(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    if (selectedTags.isEmpty) {
      _filteredTasks.clear();
    }
    filterTasksByTags(selectedTags);
    notifyListeners();
  }

  void clearSelectedTags() {
    _selectedTags.clear();
    // _filteredTasks = tasks;
    _filteredTasks.clear();
    notifyListeners();
  }

  //to filter tasks by tags
  void filterTasksByTags(List tags) {
    if (tags.isEmpty) {
      _filteredTasks.clear();
    } else {
      _filteredTasks = _tasks.where((task) {
        return tags.every((tag) => task.tags.contains(tag));
      }).toList();
    }
    notifyListeners();
  }

  void toggleSortByCreationDate() {
    _sortCriteria = SortCriteria.creationDate;
    sortTasks();
    notifyListeners();
  }

  void toggleSortByEditionDate() {
    _sortCriteria = SortCriteria.editionDate;
    sortTasks();
    notifyListeners();
  }

  void toggleSortByNameAZ() {
    _sortCriteria = SortCriteria.nameAZ;
    sortTasks();
    notifyListeners();
  }

  void toggleSortByNameZA() {
    _sortCriteria = SortCriteria.nameZA;
    sortTasks();
    notifyListeners();
  }

  void toggleNewToOld() {
    _oldToNew = !_oldToNew;
    sortTasks();
    notifyListeners();
  }

  void sortTasks() {
    List<Task> tasksToSort = filteredTasks.isNotEmpty ? _filteredTasks : _tasks;

    tasksToSort.sort((a, b) {
      switch (sortCriteria) {
        case SortCriteria.creationDate:
          return _sortByDate(a.createdAt, b.createdAt);
        case SortCriteria.editionDate:
          return _sortByDate(a.updatedAt, b.updatedAt);
        case SortCriteria.nameAZ:
          return a.content.compareTo(b.content);
        case SortCriteria.nameZA:
          return b.content.compareTo(a.content);
        default:
          return 0;
      }
    });

    if (filteredTasks.isNotEmpty) {
      _filteredTasks = tasksToSort;
    } else {
      _tasks = tasksToSort;
    }

    notifyListeners();
  }

  int _sortByDate(DateTime a, DateTime b) {
    return _oldToNew ? a.compareTo(b) : b.compareTo(a);
  }

  void removeTemporarilyAddedTags(String tag) {
    _temporarilyAddedTags.remove(tag);
    notifyListeners();
  }

  void addTemporarilyAddedTags(String tag) {
    if (!_temporarilyAddedTags.contains(tag)) {
      _temporarilyAddedTags.add(tag);
    }
    notifyListeners();
  }
}
