import 'dart:convert';

class Task {
  Task({
    required this.content,
    required this.id,
    this.tags = const [],
    this.favorite = false,
    this.isDone = false,
    this.createdAt,
    this.updatedAt,
  });

  String content;
  String id;
  List<String> tags;
  bool favorite;
  bool isDone;
  DateTime? createdAt;
  DateTime? updatedAt;


  factory Task.fromJson(String str) => Task.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        content: json["content"],
        id: json["\u0024id"] ?? "",
        tags: List<String>.from(json["tags"].map((x) => x is Map ? x["tagname"] : x)),
        favorite: json["favorite"],
        isDone: json["isDone"],
        createdAt: DateTime.parse(json["\u0024createdAt"]),
        updatedAt: DateTime.parse(json["\u0024updatedAt"]),
      );

  Map<String, dynamic> toMap() {
    final map = {
      "content": content,
      // "id": id,
      "\u0024id": id,
      "tags": tags,
      "favorite": favorite,
      "isDone": isDone,
      "\u0024createdAt": createdAt?.toIso8601String(),
      "\u0024updatedAt": updatedAt?.toIso8601String(),
    };

    return map;
  }
}
