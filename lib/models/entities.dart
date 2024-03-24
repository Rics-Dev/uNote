import 'package:objectbox/objectbox.dart';
import '../objectbox.g.dart';

@Entity()
class Task {
  @Id()
  int id;

  String name;
  String details;
  bool isDone;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  @Property(type: PropertyType.date)
  DateTime? dueDate; // Nullable dueDate

  String? priority; // Nullable priority
  // List<Tag> tags;
  // TaskList? list;

  Task({
    required this.id,
    required this.name,
    required this.details,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate, // Nullable dueDate
    this.priority, // Nullable priority
    // this.tags = const [],
    // this.list,
  });
}

@Entity()
class Tag {
  @Id()
  int id;
  String name;

  Tag({
    required this.id,
    required this.name,
  });
}

@Entity()
class TaskList {
  @Id()
  int id;

  String name;
  // List<Task> tasks;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  TaskList({
    required this.id,
    required this.name,
    // this.tasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}


