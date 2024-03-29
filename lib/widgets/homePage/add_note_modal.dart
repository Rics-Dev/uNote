import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
  final QuillController _contentController = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();
  final bool _isToolbarVisible = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // _titleController.addListener(_onEditorTextChanged);
    // _contentController.addListener(_onEditorTextChanged);
    // final notesProvider =
    //       Provider.of<NotesProvider>(context, listen: false);
    // final note = notesProvider.notes[0];
    // final jsonNote = note.json;
    // final json = jsonDecode(jsonNote);
    // _contentController.document = Document.fromJson(json);
  }

  @override
  void dispose() {
    _noteTitleController.dispose();
    _noteContentController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    // _retrieveData();
    super.dispose();
  }

  void _onEditorTextChanged() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  // void addNote(String title, String content) {
  //   if (title.isEmpty) {
  //     toastification.show(
  //       type: ToastificationType.warning,
  //       style: ToastificationStyle.minimal,
  //       context: context,
  //       title: const Text("Note must have a title"),
  //       autoCloseDuration: const Duration(seconds: 3),
  //     );
  //   } else {
  //     context.read<NotesProvider>().addNote(title, content);
  //     _noteContentController.clear();
  //     _noteTitleController.clear();
  //     Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final selectedNoteBookIndex = notesProvider.selectedNoteBook;
    return PopScope(
      onPopInvoked: (isPop) async {
        if (isPop) {
          if (!_isSaved) {
            final title = _titleController.text;
            final content = _contentController.document.toPlainText().trim();
            final json =
                jsonEncode(_contentController.document.toDelta().toJson());
            if (title.isNotEmpty || content.isNotEmpty) {
              context
                  .read<NotesProvider>()
                  .addNote(title, content, json, selectedNoteBookIndex);
            }
          }
        }
      },
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Scaffold(
          appBar: AppBar(
            title: TextField(
              onTapOutside: (event) {
                titleFocusNode.unfocus();
              },
              focusNode: titleFocusNode,
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
                hintStyle: TextStyle(
                  // color: Colors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  setState(() {
                    _isSaved = true;
                  });
                  final title = _titleController.text;
                  final content =
                      _contentController.document.toPlainText().trim();
                  final json = jsonEncode(
                      _contentController.document.toDelta().toJson());
                  if (title.isNotEmpty || content.isNotEmpty) {
                    context
                        .read<NotesProvider>()
                        .addNote(title, content, json, selectedNoteBookIndex);
                    Navigator.of(context).pop();
                  } else {
                    toastification.show(
                      type: ToastificationType.warning,
                      style: ToastificationStyle.minimal,
                      context: context,
                      title: const Text("Note must have a title or content"),
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                  }
                },
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              children: [
                QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    multiRowsDisplay: true,
                    controller: _contentController,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    focusNode: contentFocusNode,
                    child: GestureDetector(
                      onTap: () {
                        titleFocusNode.unfocus(); // Request focus
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 24.0),
                        child: QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                            placeholder: 'Add your note here...',
                            autoFocus: false,
                            controller: _contentController,
                            readOnly: false,
                            sharedConfigurations:
                                const QuillSharedConfigurations(
                              locale: Locale('en'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class NoteController {
  final TextEditingController titleController;
  final QuillController contentController;

  NoteController({
    required this.titleController,
    required this.contentController,
  });
}
