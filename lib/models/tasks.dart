import 'dart:convert'; // Importing the 'dart:convert' library for JSON encoding and decoding.

class Task {
  // Defining a class 'Task' to represent tasks.
  
  // Properties of the Task class.
  String content; // Content of the task.
  String id; // Unique identifier for the task.
  List<String> tags; // List of tags associated with the task.
  bool isDone; // Indicates whether the task is completed.
  DateTime createdAt; // Date and time when the task was created.
  DateTime updatedAt; // Date and time when the task was last updated.

  // Constructor for the Task class.
  Task({
    required this.content, // Content is required.
    required this.id, // ID is required.
    this.tags = const [], // Tags are optional, initialized as an empty list by default.
    this.isDone = false, // Completion status is optional, initialized as false by default.
    required this.createdAt, // Creation time is required.
    required this.updatedAt, // Update time is required.
  });

  // Factory constructor to create a Task object from a JSON string.
  factory Task.fromJson(String str) => Task.fromMap(json.decode(str));

  // Factory constructor to create a Task object from a Map.
  factory Task.fromMap(Map<String, dynamic> json) => Task(
        // Initializing Task object properties from the provided Map.
        content: json["content"], // Extracting content from the Map.
        id: json["\u0024id"] ?? "", // Extracting ID from the Map, with fallback to an empty string if not present.
        tags: List<String>.from(json["tags"].map((x) => x is Map ? x["tagname"] : x)), // Extracting and formatting tags from the Map.
        isDone: json["isDone"], // Extracting completion status from the Map.
        createdAt: DateTime.parse(json["\u0024createdAt"]), // Parsing creation time from string to DateTime.
        updatedAt: DateTime.parse(json["\u0024updatedAt"]), // Parsing update time from string to DateTime.
      );

  // Method to convert a Task object to a JSON string.
  String toJson() => json.encode(toMap());

  // Method to convert a Task object to a Map.
  Map<String, dynamic> toMap() {
    // Creating a Map representation of the Task object.
    final map = {
      "content": content, // Adding content to the Map.
      "\u0024id": id, // Adding ID to the Map with special prefix.
      "tags": tags, // Adding tags to the Map.
      "isDone": isDone, // Adding completion status to the Map.
      "\u0024createdAt": createdAt.toIso8601String(), // Adding creation time to the Map in ISO 8601 format.
      "\u0024updatedAt": updatedAt.toIso8601String(), // Adding update time to the Map in ISO 8601 format.
    };

    return map; // Returning the Map.
  }
}
