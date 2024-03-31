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
class Note{
  @Id()
  int id;

  String title;
  String content;
  String json;

  bool isSecured;
  bool isFavorite;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  @Backlink()
  final tags = ToMany<Tag>();

  final notebook = ToOne<NoteBook>();


  Note({
    this.id = 0,
    required this.title,
    required this.content,
    required this.json,
    this.isSecured = false,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });
}

@Entity()
class Tag {
  @Id()
  int id;

  @Unique()
  String name;

  final tasks = ToMany<Task>();

  final notes = ToMany<Note>();

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

@Entity()
class NoteBook {
  @Id()
  int id;

  String name;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  @Backlink()
  final notes = ToMany<Note>();

  NoteBook({
    this.id = 0,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}
