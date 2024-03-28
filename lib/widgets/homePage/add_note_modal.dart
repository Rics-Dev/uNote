import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../../pages/note_page.dart';
import '../../providers/note_provider.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({super.key});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();

  @override
  void dispose() {
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  void addNote(String title, String content) {
    if (title.isEmpty) {
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.minimal,
        context: context,
        title: const Text("Note must have a title"),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } else {
      context.read<NotesProvider>().addNote(title, content);
      _noteContentController.clear();
      _noteTitleController.clear();
      Navigator.of(context).pop();
    }
  }

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
            TextField(
              controller: _noteTitleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _noteContentController,
              decoration: const InputDecoration(
                hintText: 'Content',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                addNote(_noteTitleController.text, _noteContentController.text);
                // context.read<NotesProvider>().addNote(
                //     _noteTitleController.text, _noteContentController.text);
                // _noteContentController.clear();
                // _noteTitleController.clear();
                // Navigator.of(context).pop();
              },
              child: const Text('Add Note'),
            ),
          ],
        ),
      ),
    ));
  }
}
