import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasks.dart';
import 'auth_provider.dart';
import 'package:uuid/uuid.dart';

enum SortCriteria {
  creationDate,
  editionDate,
  nameAZ,
  nameZA,
}

enum FilterCriteria {
  tags,
  priority,
}

class TasksAPI extends ChangeNotifier {
  late SharedPreferences prefs;
  var uuid = const Uuid();

  List<Task> _tasks = [];
  List<String> _tags = [];
  List<String> _searchedTags = [];
  List<Task> _filteredTasks = [];
  List<Task> _searchedTasks = [];
  bool _isSearchingTasks = false;
  final List<String> _selectedTags = [];
  List<String> _temporarilyAddedTags = [];
  bool _oldToNew = true;
  DateTime? _dueDate;
  bool _isTimeSet = false;
  String? _temporarySelectedPriority;
  final List<String> _priority = ['Low', 'Medium', 'High'];
  final List<String> _selectedPriority = [];

  SortCriteria _sortCriteria = SortCriteria.creationDate;
  FilterCriteria _filterCriteria = FilterCriteria.tags;

  List<Task> get tasks => _tasks;
  List<String> get tags => _tags;
  List<String> get searchedTags => _searchedTags;
  List<Task> get filteredTasks => _filteredTasks;
  List<Task> get searchedTasks => _searchedTasks;
  bool get isSearchingTasks => _isSearchingTasks;
  List<String> get selectedTags => _selectedTags;
  List<String> get temporarilyAddedTags => _temporarilyAddedTags;
  bool get oldToNew => _oldToNew;
  SortCriteria get sortCriteria => _sortCriteria;
  FilterCriteria get filterCriteria => _filterCriteria;
  DateTime? get dueDate => _dueDate;
  bool get isTimeSet => _isTimeSet;
  String? get temporarySelectedPriority => _temporarySelectedPriority;
  List<String> get priority => _priority;
  List<String> get selectedPriority => _selectedPriority;

  TasksAPI() {
    fetchTasks();
  }


  Future<void> _updateLocalStorage(List<Task> tasks, List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'tasks', tasks.map((task) => json.encode(task.toJson())).toList());
    await prefs.setStringList('tags', tags);
  }

  Future<void> fetchTasks() async {
    try {
      prefs = await SharedPreferences.getInstance();
      await _fetchLocalData();
    } finally {
      notifyListeners();
    }
  }

  //to create tasks and tags
  Future<void> createTask({required String taskContent}) async {
    final taskId = uuid.v4();
    await _createLocalTask(task: taskContent, taskId: taskId);


    _temporarilyAddedTags = [];
    _temporarySelectedPriority = null;
    _dueDate = null;
    notifyListeners();
  }

  //to delete tasks
  Future<void> deleteTask({required String taskId}) async {
    final removedTask = await _deleteLocalTask(taskId: taskId);
    await _deleteUnusedLocalTag(removedTask);
  }

  Future<void> _fetchLocalData() async {
    final cachedTasks = prefs.getStringList('tasks');
    final cachedTags = prefs.getStringList('tags');
    // await prefs.clear();

    if (cachedTasks != null) {
      _tasks = cachedTasks
          .map((jsonString) => Task.fromJson(json.decode(jsonString)))
          .toList();
    }

    if (cachedTags != null) {
      _tags = cachedTags;
    }
    notifyListeners();
  }


  Future<void> _createLocalTask({
    required String task,
    required String taskId,
  }) async {
    for (var tag in _temporarilyAddedTags) {
      if (!_tags.contains(tag)) {
        _tags.add(tag);
      }
    }
    final newTask = Task.fromMap({
      'content': task,
      '\u0024id': taskId,
      'tags': _temporarilyAddedTags,
      'isDone': false,
      '\u0024createdAt': DateTime.now().toIso8601String(),
      '\u0024updatedAt': DateTime.now().toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': temporarySelectedPriority,
    });
    if (selectedTags.isNotEmpty || selectedPriority.isNotEmpty) {
      _filteredTasks.add(newTask);
    }
    _tasks.add(newTask);
    notifyListeners();
    await _updateLocalStorage(_tasks, _tags);
  }




  Future<Task?> _deleteLocalTask({required String taskId}) async {
    Task? removedTask;
    _tasks.removeWhere((task) {
      if (task.id == taskId) {
        removedTask = task;
        return true;
      }
      return false;
    });
    if (selectedTags.isNotEmpty || selectedPriority.isNotEmpty) {
      _filteredTasks.removeWhere((task) => task.id == taskId);
    }
    notifyListeners();
    await _updateLocalStorage(_tasks, _tags);
    return removedTask;
  }

  Future<void> _deleteUnusedLocalTag(Task? removedTask) async {
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
        }
      }
    }
  }




  void deleteTag(String tag) async {
    await _deleteLocalTag(tag);
  }

  Future<void> _deleteLocalTag(String tag) async {
    _tags.remove(tag);
    for (var task in _tasks) {
      if (task.tags.contains(tag)) {
        // If the task contains the tag, remove it inside the task
        task.tags.remove(tag);
      }
    }
    notifyListeners();
    await _updateLocalStorage(_tasks, _tags);
  }


  //to update tasks (for now only when it's done)
  void updateTask({required String taskId, required bool isDone}) async {
    await _updateLocalTask(taskId: taskId, isDone: isDone);
  }

  Future<void> _updateLocalTask(
      {required String taskId, required bool isDone}) async {
    final int index = _tasks.indexWhere((task) => task.id == taskId);
    _tasks[index].isDone = isDone;
    notifyListeners();
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
    _isSearchingTasks = true;
    if (searchedTasks.isEmpty) {
      _searchedTasks.clear();
    }
    _searchedTasks = searchedTasks;
    notifyListeners();
  }

  void setIsSearching(bool bool) {
    _isSearchingTasks = bool;
    notifyListeners();
  }

  void toggleFilterByTags() {
    _filterCriteria = FilterCriteria.tags;
    notifyListeners();
  }

  void toggleFilterByPriority() {
    _filterCriteria = FilterCriteria.priority;
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

  void togglePrioritySelection(String priority) {
    if (_selectedPriority.contains(priority)) {
      _selectedPriority.remove(priority);
    } else {
      _selectedPriority.add(priority);
    }
    if (_selectedPriority.isEmpty) {
      _filteredTasks.clear();
    }
    filterTasksByPriority(_selectedPriority);
    notifyListeners();
  }

  void filterTasksByPriority(List priority) {
    if (priority.isEmpty) {
      _filteredTasks.clear();
    } else {
      _filteredTasks = _tasks.where((task) {
        return priority.every((priority) => task.priority == priority);
      }).toList();
    }
    notifyListeners();
  }

  void clearSelectedPriority() {
    _selectedPriority.clear();
    // _filteredTasks = tasks;
    _filteredTasks.clear();
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

  // priority management part
  void setTemporarySelectedPriority(String? s) {
    _temporarySelectedPriority = s;
    notifyListeners();
  }

  //part to set due date
  void setDueDate(DateTime? selectedDay) {
    _dueDate = selectedDay;
    notifyListeners();
  }

  void setTimeSet(bool bool) {
    _isTimeSet = bool;
    notifyListeners();
  }
}

