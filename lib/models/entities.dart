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

  @Backlink()
  final tags = ToMany<Tag>();

  final list = ToOne<TaskList>();

  Task({
    this.id = 0,
    required this.name,
    required this.details,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate, // Nullable dueDate
    this.priority, // Nullable priority
  });
}

@Entity()
class Tag {
  @Id()
  int id;

  @Unique()
  String name;

  final tasks = ToMany<Task>();

  Tag({
    this.id = 0,
    required this.name,
  });
}

@Entity()
class TaskList {
  @Id()
  int id;

  String name;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  @Backlink()
  final tasks = ToMany<Task>();

  TaskList({
    this.id = 0,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}
