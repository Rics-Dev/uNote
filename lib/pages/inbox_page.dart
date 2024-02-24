import 'package:flutter/material.dart';

import '../models/tasks.dart';

class InboxPage extends StatefulWidget {
  final List<Task> tasks;
  const InboxPage({super.key, required this.tasks});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<Task> get tasks => widget.tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              // Build your task item here
              return ListTile(
                title: Text(tasks[index].content),
                // Add more details as needed
              );
            },
          ),
        ),
      ],
    );
  }
}
