import 'dart:convert';

enum Priority {
  small,
  medium,
  high,
}

class Task {
  String content;
  String id;
  List<String> tags;
  bool isDone;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? dueDate; // Nullable dueDate
  Priority? priority; // Nullable priority

  Task({
    required this.content,
    required this.id,
    this.tags = const [],
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate, // Nullable dueDate
    this.priority, // Nullable priority
  });

  factory Task.fromJson(String str) => Task.fromMap(json.decode(str));

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        content: json["content"],
        id: json["\u0024id"] ?? "",
        tags: List<String>.from(
            json["tags"].map((x) => x is Map ? x["tagname"] : x)),
        isDone: json["isDone"],
        createdAt: DateTime.parse(json["\u0024createdAt"]),
        updatedAt: DateTime.parse(json["\u0024updatedAt"]),
        dueDate: json["dueDate"] != null
            ? DateTime.parse(json["dueDate"])
            : null, // Parse dueDate from JSON or set to null if not present
        priority: json["priority"] != null
            ? Priority.values[json["priority"]]
            : null, // Parse priority from JSON or set to null if not present
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    final map = {
      "content": content,
      "\u0024id": id,
      "tags": tags,
      "isDone": isDone,
      "\u0024createdAt": createdAt.toIso8601String(),
      "\u0024updatedAt": updatedAt.toIso8601String(),
      "dueDate": dueDate?.toIso8601String(), // Convert dueDate to ISO 8601 string or set to null if not present
      "priority": priority?.index, // Convert priority to index or set to null if not present
    };

    return map;
  }
}
