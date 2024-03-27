import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';
import '../objectbox.g.dart';

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

class TasksProvider extends ChangeNotifier {
  Box<Task> taskBox = objectbox.taskBox;
  Box<Tag> tagBox = objectbox.tagBox;
  Box<TaskList> taskListBox = objectbox.taskListBox;

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  List<Task> _searchedTasks = [];
  List<Tag> _tags = [];
  List<Tag> _temporarilyAddedTags = [];
  final List<Tag> _searchedTags = [];
  String? _temporarySelectedPriority;
  DateTime? _dueDate;
  bool _oldToNew = true;
  String _disposition = 'List';
  final List<Tag> _selectedTags = [];
  final List<String> _selectedPriority = [];
  final List<String> _priority = ['Low', 'Medium', 'High'];
  bool _isSearchingTasks = false;
  bool _isTimeSet = false;
  List<TaskList> _taskLists = [];
  TaskList _temporarilyAddedList =
      TaskList(name: '', createdAt: DateTime.now(), updatedAt: DateTime.now());

  List<bool> isKeyBoardOpenedList = [];
  List<List<bool>> isEditingTask = [];

  SortCriteria _sortCriteria = SortCriteria.creationDate;
  FilterCriteria _filterCriteria = FilterCriteria.priority;

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
  SortCriteria get sortCriteria => _sortCriteria;
  FilterCriteria get filterCriteria => _filterCriteria;
  bool get isTimeSet => _isTimeSet;
  TaskList get temporarilyAddedList => _temporarilyAddedList;
  List<TaskList> get taskLists => _taskLists;
  String get disposition => _disposition;
  bool get oldToNew => _oldToNew;

  TasksProvider() {
    _init();
  }

  void _init() async {
    // taskListBox.removeAll();
    final taskList = taskListBox.getAll();
    final tasksStream = objectbox.getTasks();
    tasksStream.listen(_onTasksChanged);
    final tagsStream = objectbox.getTags();
    tagsStream.listen(_onTagsChanged);
    final taskListStream = objectbox.getTaskLists();
    taskListStream.listen(_onTaskListsChanged);
  }

  void _onTasksChanged(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void _onTagsChanged(List<Tag> tags) {
    _tags = tags;
    notifyListeners();
  }

  void _onTaskListsChanged(List<TaskList> taskLists) {
    _taskLists = taskLists;
    isKeyBoardOpenedList = List.filled(_taskLists.length, false);
    isEditingTask = List.generate(
        _taskLists.length,
        (index) =>
            List.filled(_taskLists[index].tasks.length, false, growable: true),
        growable: true);
    notifyListeners();
  }

  void addTask(String taskContent) {
    //-------------------------------------------------------

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

    //-------------------------------------------

    //-------------------------------------------

    final task = Task(
      name: taskContent,
      details: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      priority: temporarySelectedPriority,
    );
    if (selectedTags.isNotEmpty || selectedPriority.isNotEmpty) {
      _filteredTasks.add(task);
    }

    final taskList = _temporarilyAddedList;
    if (taskList.name.isNotEmpty) {
      final alreadyExistingTaskList = taskListBox
          .query(TaskList_.name.equals(taskList.name))
          .build()
          .findFirst();
      if (alreadyExistingTaskList != null) {
        task.list.target = alreadyExistingTaskList;
        alreadyExistingTaskList.tasks.add(task);
        taskListBox.put(alreadyExistingTaskList);
      } else {
        task.list.target = taskList;
        // taskList.tasks.add(task); // ne fonctionne pas
        taskListBox.put(taskList);
      }
    }

    task.tags.addAll(tags);

    taskBox.put(task);

    _selectedTags.clear();
    _selectedPriority.clear();
    _temporarilyAddedList.id = 0;
    _temporarilyAddedList.name = '';
    _temporarilyAddedTags = [];
    _temporarySelectedPriority = null;
    _dueDate = null;
    notifyListeners();
  }

  //Done
  verifyExistingList(String listName) {
    return taskListBox
        .query(TaskList_.name.equals(listName))
        .build()
        .findFirst();
  }

  //Done
  void addList(String listName) {
    final taskList = TaskList(
        name: listName, createdAt: DateTime.now(), updatedAt: DateTime.now());
    taskListBox.put(taskList);

    notifyListeners();
  }

  //Done
  void deleteList(int id) {
    final taskList = taskListBox.get(id);
    if (taskList!.tasks.isNotEmpty) {
      for (final task in taskList.tasks) {
        taskBox.remove(task.id);
      }
    }
    taskListBox.remove(id);
    // notifyListeners();
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
    for (final list in taskLists) {
      if (list.tasks.where((element) => element.id == taskId).isNotEmpty) {
        list.tasks.remove(removedTask);
        taskListBox.put(list);
      }
    }
    taskBox.remove(taskId);
  }

  void updateTask(int taskId, bool isDone) async {
    final updatedTask = taskBox.get(taskId);
    if (updatedTask != null) {
      updatedTask.isDone = isDone;
      updatedTask.updatedAt = DateTime.now();
      if (updatedTask.list.target != null) {
        final taskList = updatedTask.list.target!;
        taskList.updatedAt = DateTime.now();
        taskListBox.put(taskList);
      }
      taskBox.put(updatedTask);
    }
    notifyListeners();
  }

  void updateTaskName(int id, String value) {
    final task = taskBox.get(id);
    if (task != null) {
      task.name = value;
      task.updatedAt = DateTime.now();
      if (task.list.target != null) {
        final taskList = task.list.target!;
        taskList.updatedAt = DateTime.now();
        taskListBox.put(taskList);
      }
      taskBox.put(task);
    }
    notifyListeners();
  }

  updateTasksOrder(int oldIndex, int newIndex) async {
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
    notifyListeners();

    // await taskBox.putManyAsync(tasks);
  }

  void deleteTag(Tag tag) {
    tagBox.remove(tag.id);
    notifyListeners();
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

  void setTemporarySelectedPriority(String? priority) {
    _temporarySelectedPriority = priority;
    notifyListeners();
  }

  void addTemporarilyAddedList(String s) {
    _temporarilyAddedList.name = s;
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

  // ----------------- Filter and Search Section ------------------------------

  void toggleFilterByTags() {
    _filterCriteria = FilterCriteria.tags;
    notifyListeners();
  }

  void toggleFilterByPriority() {
    _filterCriteria = FilterCriteria.priority;
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

  void togglePrioritySelection(String priority) {
    if (_selectedPriority.contains(priority)) {
      _selectedPriority.remove(priority);
    } else {
      _selectedPriority.clear();
      _selectedPriority.add(priority);
    }
    if (_selectedPriority.isEmpty) {
      _filteredTasks.clear();
    }
    filterTasksByPriority(_selectedPriority);
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
          return sortByDate(a.createdAt, b.createdAt);
        case SortCriteria.editionDate:
          return sortByDate(a.updatedAt, b.updatedAt);
        case SortCriteria.nameAZ:
          return a.name.compareTo(b.name);
        case SortCriteria.nameZA:
          return b.name.compareTo(a.name);
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

  int sortByDate(DateTime a, DateTime b) {
    return _oldToNew ? a.compareTo(b) : b.compareTo(a);
  }

  void setDisposition(String s) {
    _disposition = s;
    notifyListeners();
  }

  void setTemporaySelectedList(TaskList taskList) {
    _temporarilyAddedList = taskList;
  }

  void setIsKeyboardOpened(bool bool, int index) {
    isKeyBoardOpenedList[index] = bool;
    notifyListeners();
  }

  void setTemporaySelectedTask(Task task) {
    _temporarilyAddedList.tasks.add(task);
  }

  void setIsEditingTask(bool bool, int index, int taskId) {
    if (taskId == -1) {
      isEditingTask[index] = List.filled(isEditingTask[index].length, bool);
      notifyListeners();
      return;
    }
    isEditingTask[index][taskId] = bool;
    notifyListeners();
  }
}
