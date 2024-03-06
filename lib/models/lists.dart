import 'dart:convert';
import 'tasks.dart';

class ListItem {
  String listName;
  String id;
  List<Task> tasks;
  DateTime createdAt;
  DateTime updatedAt;

  ListItem({
    required this.listName,
    required this.id,
    this.tasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListItem.fromJson(String str) => ListItem.fromMap(json.decode(str));

  factory ListItem.fromMap(Map<String, dynamic> json) => ListItem(
        listName: json["listname"],
        id: json["\u0024id"] ?? "",
        tasks: List<Task>.from((json["tasks"] ?? []).map((x) => Task.fromMap(x))),
        createdAt: DateTime.parse(json["\u0024createdAt"]),
        updatedAt: DateTime.parse(json["\u0024updatedAt"]),
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    final map = {
      "listname": listName,
      "\u0024id": id,
      "tasks": List<dynamic>.from(tasks.map((x) => x.toMap())),
      "\u0024createdAt": createdAt.toIso8601String(),
      "\u0024updatedAt": updatedAt.toIso8601String(),
    };
    return map;
  }
}