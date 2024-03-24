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
    final uniqueTags = <Tag>[];
    // Add unique tags to the _tags list
    for (var tpTag in _temporarilyAddedTags) {
      if (!_tags.any((tag) => tag.name == tpTag.name)) {
        _tags.add(tpTag);
        uniqueTags.add(tpTag);
      }
    }

    // Insert unique tags into the tags table

    await database.batch((batch) {
      batch.insertAll(
        database.tags,
        uniqueTags.map((tag) => TagsCompanion(name: Value(tag.name))).toList(),
      );
    });

    for (var tag in tags) {
      database.update(database.tags)
        ..where((t) =>
            t.name.isIn(_temporarilyAddedTags.map((e) => e.name).toList()))
        ..write(TagsCompanion(numberOfTasks: Value(tag.numberOfTasks + 1)));
    }

    _tags.clear();
    _tags.addAll(await database.select(database.tags).get());

    // Insert the new task into the tasks table
    final newTaskCompanion = TasksCompanion(
      name: Value(taskContent),
    );
    final insertedTaskId =
        await database.into(database.tasks).insert(newTaskCompanion);

    // Fetch the newly inserted task
    final newTask = await (database.select(database.tasks)
          ..where((t) => t.id.equals(insertedTaskId)))
        .getSingle();

    final insertedTags = await (database.select(database.tags)
          ..where((t) =>
              t.name.isIn(_temporarilyAddedTags.map((e) => e.name).toList())))
        .get();

    // Associate the new task with the selected tags in the TaskTag table
    for (final tag in insertedTags) {
      final tagId = tag.id;
      if (tagId != null) {
        await database.into(database.taskTag).insert(
              TaskTagCompanion(
                taskId: Value(newTask.id),
                tagId: Value(tagId),
              ),
            );
      }
    }

    // Add the new task to the filtered tasks and tasks lists if necessary
    if (_selectedTags.isNotEmpty || _selectedPriority.isNotEmpty) {
      _filteredTasks.add(newTask);
    }
    _tasks.add(newTask);

    notifyListeners(); // Notify listeners about the list change

    _temporarilyAddedTags = [];
    _temporarySelectedPriority = null;
    _dueDate = null;
  }

  void addTemporarilyAddedTags(String tag) {
    if (!_temporarilyAddedTags.contains(tag)) {
      final newTag = Tag(
        id: null,
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

  // Future<int> getTaskCountsForTags(int? id) async {
  //   final count = await (database.select(database.taskTag)
  //         ..where((t) => t.tagId.equals(id!)))
  //       .get();
  //   return count.length;
  // }
}

    // final newTask = Task(
    //   id: const Value.absent(), // Let the database generate the ID automatically
    //   name: taskContent,
    //   isDone: false, // Assuming a new task is not done by default
    //   createdAt: DateTime.now(), // Set the createdAt time to the current timestamp
    //   updatedAt: DateTime.now(), // Set the updatedAt time to the current timestamp
    // );