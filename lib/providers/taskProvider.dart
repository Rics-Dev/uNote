import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:utask/database/database.dart';
import 'package:uuid/uuid.dart';

class TasksProvider extends ChangeNotifier {
  final database = MyDatabase();
  final List<Task> _tasks = [];
  final List<Tag> _tags = [];
  final List<Tag> _searchedTags = [];
  List<Tag> _temporarilyAddedTags = [];
  String? _temporarySelectedPriority;
  final List<String> _priority = ['Low', 'Medium', 'High'];
  DateTime? _dueDate;
  final List<Tag> _selectedTags = [];
  final List<String> _selectedPriority = [];
  List<Task> _filteredTasks = [];
  List<Task> _searchedTasks = [];
  bool _isSearchingTasks = false;



  List<Tag> get tags => _tags;
  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;
  List<Tag> get selectedTags => _selectedTags;
  List<Tag> get searchedTags => _searchedTags;
  List<Tag> get temporarilyAddedTags => _temporarilyAddedTags;
  List<String> get selectedPriority => _selectedPriority;
  List<String> get priority => _priority;
  DateTime? get dueDate => _dueDate;
  String? get temporarySelectedPriority => _temporarySelectedPriority;
  List<Task> get searchedTasks => _searchedTasks;
  bool get isSearchingTasks => _isSearchingTasks;



  TasksProvider() {
    fetchTasks();
  }

  fetchTasks() async {
    final tasks = await database.select(database.tasks).get();
    final tags = await database.select(database.tags).get();
    _tasks.clear();
    _tasks.addAll(tasks);
    _tags.clear();
    _tags.addAll(tags);
    notifyListeners();
  }

  Future<void> createTask({required String taskContent}) async {
    for (final tag in _temporarilyAddedTags) {
      await database.into(database.tags).insert(
          TagsCompanion(
            name: Value(tag.name),
          ),
          onConflict: DoUpdate(
            (old) => TagsCompanion.custom(
                numberOfTasks: old.numberOfTasks + const Constant(1)),
          ));
    }

    _tags.clear();
    _tags.addAll(await database.select(database.tags).get());

    // Insert the new task into the tasks table
    final newTaskCompanion = TasksCompanion(
      name: Value(taskContent),
    );
    final newTask =
        await database.into(database.tasks).insertReturning(newTaskCompanion);

    final insertedTags = await (database.select(database.tags)
          ..where((t) =>
              t.name.isIn(_temporarilyAddedTags.map((e) => e.name).toList())))
        .get();

    // Associate the new task with the selected tags in the TaskTag table
    for (final tag in insertedTags) {
      final tagName = tag.name;
      if (tagName != null) {
        await database.into(database.taskTag).insert(
              TaskTagCompanion(
                taskId: Value(newTask.id),
                tagName: Value(tagName),
              ),
            );
      }
    }

    if (_selectedTags.isNotEmpty || _selectedPriority.isNotEmpty) {
      _filteredTasks.add(newTask);
    }
    _tasks.add(newTask);

    _temporarilyAddedTags = [];
    _temporarySelectedPriority = null;
    _dueDate = null;
  }

  void addTemporarilyAddedTags(String tag) {
    if (!_temporarilyAddedTags.contains(tag)) {
      final newTag = Tag(
        name: tag,
        numberOfTasks: 1,
      );
      _temporarilyAddedTags.add(newTag);
    }
    notifyListeners();
  }

  void removeTemporarilyAddedTags(Tag tag) {
    _temporarilyAddedTags.remove(tag);
    notifyListeners();
  }

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

  void filterTasksByTags(List<Tag> selectedTags) async {
    if (selectedTags.isEmpty) {
      _filteredTasks.clear();
    } else {
      final query = (database.select(database.tasks).join([
        innerJoin(database.taskTag,
            database.taskTag.taskId.equalsExp(database.tasks.id)),
        innerJoin(database.tags,
            database.tags.name.equalsExp(database.taskTag.tagName))
      ])
      ..where(database.tags.name.isIn(selectedTags.map((e) => e.name).toList())));


      _filteredTasks =  await query.map((row) => row.readTable(database.tasks)).get();
    }
    notifyListeners();
  }
}
