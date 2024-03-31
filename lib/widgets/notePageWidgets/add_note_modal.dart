import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../../models/entities.dart';
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
  bool _isSaved = false;

  int _wordCount = 0;

  @override
  void dispose() {
    _noteTitleController.dispose();
    _noteContentController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  // void _onEditorTextChanged() {
  //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  // }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final newNote = notesProvider.newNote;
    final selectedNoteBookIndex = notesProvider.selectedNoteBook;

    // if (selectedNoteBookIndex == 0) {
    //   newNote.isSecured = true;
    // }else{
    //   newNote.isSecured = false;
    // }

    return PopScope(
      onPopInvoked: (isPop) async {
        if (isPop) {
          if (!_isSaved) {
            final title = _titleController.text;
            final content = _contentController.document.toPlainText().trim();
            final json =
                jsonEncode(_contentController.document.toDelta().toJson());
            if (title.isNotEmpty) {
              context.read<NotesProvider>().addNote(title, content, json,
                  newNote.isSecured, newNote.isFavorite, selectedNoteBookIndex);
            }
          }
        }
      },
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 1,
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
                  if (title.isNotEmpty) {
                    context.read<NotesProvider>().addNote(
                        title,
                        content,
                        json,
                        newNote.isSecured,
                        newNote.isFavorite,
                        selectedNoteBookIndex);
                    Navigator.of(context).pop();
                  } else {
                    toastification.show(
                      type: ToastificationType.warning,
                      style: ToastificationStyle.flat,
                      context: context,
                      title: const Text("Note must have a title"),
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                  }
                },
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12),
                  child: Row(
                    children: [
                      Visibility(
                        visible: !newNote.isSecured,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            textStyle: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                            padding: const EdgeInsets.all(4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            showAddNoteBookDialog(context, newNote);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.book_rounded),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                newNote.notebook.target != null
                                    ? newNote.notebook.target!.name.isNotEmpty
                                        ? newNote.notebook.target!.name
                                        : '+ Notebook'
                                    : '+ Notebook',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            newNote.isSecured = !newNote.isSecured;
                          });
                        },
                        icon: newNote.isSecured
                            ? const Icon(
                                Icons.shield_rounded,
                                size: 28,
                                color: Color.fromARGB(255, 0, 73, 133),
                              )
                            : const Icon(Icons.shield_outlined, size: 28),
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       currentNote.isFavorite = !currentNote.isFavorite;
                      //     });
                      //   },
                      //   icon: currentNote.isFavorite
                      //       ? const Icon(Icons.star,
                      //           size: 28,
                      //           color: Color.fromARGB(255, 0, 73, 133))
                      //       : const Icon(Icons.star_border_outlined, size: 28),
                      // ),
                    ],
                  ),
                ),
                QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    toolbarSectionSpacing: -10,

                    // axis: Axis.horizontal,
                    // toolbarSize: 36.0,
                    multiRowsDisplay: false,
                    controller: _contentController,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 24.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Words: $_wordCount',
                      ),
                      Text(
                        newNote.createdAt.toString().substring(0, 16),
                      ),
                    ],
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
                            onTapOutside: (event, titleFocusNode) {
                              setState(() {
                                _wordCount = _contentController.document
                                        .toPlainText()
                                        .trim()
                                        .isNotEmpty
                                    ? _contentController.document
                                        .toPlainText()
                                        .trim()
                                        .split(RegExp(r'\s+'))
                                        .length
                                    : 0;
                              });
                            },
                            placeholder: 'Add your note here...',
                            autoFocus: true,
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

  Future<dynamic> showAddNoteBookDialog(BuildContext context, Note note) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => AddNoteBook(note: note),
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
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
