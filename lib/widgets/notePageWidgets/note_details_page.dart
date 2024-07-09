import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../../models/entities.dart';
import '../../providers/note_provider.dart';
import 'add_note_to_book.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, required this.note});
  final Note note;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final QuillController _contentController = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  FocusNode contentFocusNode = FocusNode();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    final jsonNote = widget.note.json;
    final json = jsonDecode(jsonNote);
    _contentController.document = Document.fromJson(json);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final note = notesProvider.getNoteById(widget.note.id) ?? widget.note;
    final selectedNoteBookIndex = notesProvider.selectedNoteBook;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Scaffold(
          appBar: AppBar(
            elevation: 3,
            title: TextField(
              readOnly: _isEditing ? false : true,
              // focusNode: titleFocusNode,
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              _isEditing
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          final title = _titleController.text;
                          final content =
                              _contentController.document.toPlainText().trim();
                          final json = jsonEncode(
                              _contentController.document.toDelta().toJson());
                          if (title.isNotEmpty || content.isNotEmpty) {
                            context.read<NotesProvider>().updateNote(note.id,
                                title, content, json, selectedNoteBookIndex);
                          }
                        });
                      },
                      icon: const Icon(Icons.done),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit),
                    ),
              IconButton(
                  onPressed: () {
                    context.read<NotesProvider>().deleteNote(note.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.delete,
                  )),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Visibility(
                      visible: !note.isSecured,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          textStyle:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                          padding: const EdgeInsets.all(4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          showAddNoteToBookDialog(context, note);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.book_rounded),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(note.notebook.target?.name ?? '+ Notebook'),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        context.read<NotesProvider>().updateSecuredNote(
                              note.id,
                            );
                      },
                      icon: note.isSecured
                          ? const Icon(
                              Icons.shield_rounded,
                              size: 28,
                              color: Color.fromARGB(255, 0, 73, 133),
                            )
                          : const Icon(Icons.shield_outlined, size: 28),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     context.read<NotesProvider>().updateFavoriteNote(
                    //           note.id,
                    //         );
                    //   },
                    //   icon: note.isFavorite
                    //       ? const Icon(Icons.star,
                    //           size: 28, color: Color.fromARGB(255, 0, 73, 133))
                    //       : const Icon(Icons.star_border_outlined, size: 28),
                    // ),
                  ],
                ),
              ),
              Visibility(
                visible: _isEditing,
                child: QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    toolbarSize: 50,
                    multiRowsDisplay: false,
                    controller: _contentController,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, top: 12.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Words: ${note.content.trim().isNotEmpty ? note.content.trim().split(RegExp(r'\s+')).length : 0}',
                    ),
                    Text(
                      note.updatedAt.toString().substring(0, 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Focus(
                  focusNode: contentFocusNode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 14),
                    child: QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        // onImagePaste: (imageBytes) {

                        // },
                        placeholder: 'Note Content...',
                        // readOnly: _isEditing ? false : true,
                        // autoFocus: true,
                        controller: _contentController,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> showAddNoteToBookDialog(BuildContext context, Note note) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => AddNoteToBook(note: note),
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
    );
  }
}
