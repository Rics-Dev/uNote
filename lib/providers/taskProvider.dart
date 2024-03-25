import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';
import '../objectbox.g.dart';

class TasksProvider extends ChangeNotifier {
  Box<Task> taskBox = objectbox.taskBox;
  Box<Tag> tagBox = objectbox.tagBox;

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  List<Task> _searchedTasks = [];
  List<Tag> _tags = [];
  List<Tag> _temporarilyAddedTags = [];
  final List<Tag> _searchedTags = [];
  String? _temporarySelectedPriority;
  DateTime? _dueDate;
  final List<Tag> _selectedTags = [];
  final List<String> _selectedPriority = [];
  final List<String> _priority = ['Low', 'Medium', 'High'];
  bool _isSearchingTasks = false;

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;
  List<Task> get searchedTasks => _searchedTasks;
  List<Tag> get tags => _tags;
  List<Tag> get temporarilyAddedTags => _temporarilyAddedTags;
  List<Tag> get searchedTags => _searchedTags;
  String? get temporarySelectedPriority => _temporarySelectedPriority;
  DateTime? get dueDate => _dueDate;
  List<Tag> get selectedTags => _selectedTags;
  List<String> get selectedPriority => _selectedPriority;
  List<String> get priority => _priority;
  bool get isSearchingTasks => _isSearchingTasks;

  TasksProvider() {
    _init();
  }

  void _init() async {
    final tasksStream = objectbox.getTasks();
    tasksStream.listen(_onTasksChanged);
    final tagsStream = objectbox.getTags();
    tagsStream.listen(_onTagsChanged);
  }

  void _onTasksChanged(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void _onTagsChanged(List<Tag> tags) {
    _tags = tags;
    notifyListeners();
  }

  void addTask(String taskContent) {
    final List<Tag> alreadyExistingTags = tagBox
        .query(
            Tag_.name.oneOf(_temporarilyAddedTags.map((e) => e.name).toList()))
        .build()
        .find();

    final List<Tag> newTags = _temporarilyAddedTags
        .where((element) =>
            !alreadyExistingTags.any((e) => e.name == element.name))
        .toList();

    final Set<Tag> tags = {...alreadyExistingTags, ...newTags};

    for (final tag in tags) {
      tagBox.put(tag);
    }

    final task = Task(
      name: taskContent,
      details: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    task.tags.addAll(tags);
    taskBox.put(task);

    _temporarilyAddedTags = [];
    _temporarySelectedPriority = null;
    _dueDate = null;
    notifyListeners();
  }

  void deleteTask(int taskId) {
    final removedTask = taskBox.get(taskId);

    if (removedTask != null && removedTask.tags.isNotEmpty) {
      final List<Tag> tagsToRemove = removedTask.tags.toList();
      for (final tag in tagsToRemove) {
        bool isTagUsed = false;
        final otherTasks = _tasks.where((element) => element.id != taskId);
        for (final task in otherTasks) {
          if (task.tags.any((element) => element.name == tag.name)) {
            isTagUsed = true;
            break;
          }
        }
        tag.tasks.remove(removedTask);
        tagBox.put(tag);
        if (!isTagUsed) {
          tagBox.remove(tag.id);
        }
      }
    }
    taskBox.remove(taskId);
  }

  //Done
  void addTemporarilyAddedTags(String tag) {
    final tagObject = Tag(name: tag);
    if (!_temporarilyAddedTags.contains(tagObject)) {
      _temporarilyAddedTags.add(tagObject);
    }
    notifyListeners();
  }

  //Done
  void removeTemporarilyAddedTags(Tag tag) {
    _temporarilyAddedTags.removeWhere((element) => element.name == tag.name);
    notifyListeners();
  }

  //Done
  void toggleTagSelection(Tag tag) {
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

  //Done
  void clearSelectedTags() {
    _selectedTags.clear();
    _filteredTasks.clear();
    notifyListeners();
  }

  void setSearchedTags(List<Tag> tags) {
    _searchedTags.clear();
    _searchedTags.addAll(tags);
    notifyListeners();
  }

  //Done
  void filterTasksByTags(List<Tag> selectedTags) {
    if (selectedTags.isEmpty) {
      _filteredTasks.clear();
    } else {
      _filteredTasks = _tasks
          .where((task) => selectedTags.every(
              (tag) => task.tags.any((element) => element.name == tag.name)))
          .toList();
    }
    notifyListeners();
  }

  //Done
  void setIsSearching(bool bool) {
    _isSearchingTasks = bool;
    notifyListeners();
  }

  //Done
  void setSearchedTasks(List<Task> suggestions) {
    _isSearchingTasks = true;
    if (suggestions.isEmpty) {
      _searchedTasks.clear();
    }
    _searchedTasks = suggestions;
    notifyListeners();
  }
}
