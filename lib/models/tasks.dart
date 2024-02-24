import 'dart:convert';

class Task {
  Task({
    required this.content,
    required this.id,
    this.tags = const [],
    this.favorite = false,
    this.isDone = false,
  });

  String content;
  String id;
  List<String> tags;
  bool favorite;
  bool isDone;


  factory Task.fromJson(String str) => Task.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        content: json["content"],
        id: json["\u0024id"] ?? "",
        tags: List<String>.from(json["tags"].map((x) => x)),
        favorite: json["favorite"],
        isDone: json["isDone"],
      );

  Map<String, dynamic> toMap() {
    final map = {
      "content": content,
      "id": id,
      "tags": tags,
      "favorite": favorite,
      "isDone": isDone,
    };

    return map;
  }
}
