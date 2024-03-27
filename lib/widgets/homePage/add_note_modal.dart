import 'package:flutter/material.dart';

class AddNoteView extends StatelessWidget {
  const AddNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Description',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Add Note'),
            ),
          ],
        ),
      ),
    ));
  }
}
