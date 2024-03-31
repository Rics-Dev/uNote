import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/entities.dart';
import '../../providers/note_provider.dart';

class AddNoteToBook extends StatefulWidget {
  const AddNoteToBook({super.key, required this.note});
  final Note note;

  @override
  State<AddNoteToBook> createState() => _AddNoteToBookState();
}

class _AddNoteToBookState extends State<AddNoteToBook> {
  final TextEditingController noteBookController = TextEditingController();

  @override
  void dispose() {
    noteBookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final noteBooks = context.watch<NotesProvider>().noteBooks;
    final searchedNoteBooks = context.watch<NotesProvider>().searchedNoteBooks;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        // padding: const EdgeInsets.only(top: 8),
        // width: MediaQuery.of(context).size.width * 0.90,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Text(
              'Add NoteBook',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: noteBookController,
                  decoration: const InputDecoration(
                    labelText: 'Add NoteBook or select already existing ones',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onChanged: (String value) {
                    searchNoteBook(noteBookController.text);
                  },
                  onSubmitted: (_) {
                    if (_.isNotEmpty) {
                      final noteBookId = context
                          .read<NotesProvider>()
                          .addNotebook(NoteBook(
                              name: noteBookController.text,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now()));
                      context
                          .read<NotesProvider>()
                          .addNoteToNoteBook(noteBookId, widget.note.id);
                      noteBookController.clear();
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Visibility(
              visible: searchedNoteBooks.isEmpty,
              child: const Center(
                child: Text('Add a new NoteBook'),
              ),
            ),
            Visibility(
              visible: searchedNoteBooks.isNotEmpty,
              child: Expanded(
                child: GridView.extent(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  childAspectRatio: 2.5,
                  maxCrossAxisExtent: 150.0,
                  mainAxisSpacing: 12.0, // spacing between rows
                  crossAxisSpacing: 8.0, // spacing between columns
                  children: [
                    ...searchedNoteBooks.map((noteBook) {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<NotesProvider>()
                                .addNoteToNoteBook(noteBook.id, widget.note.id);
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.book_rounded,
                            size: 18,
                            color:
                                noteBook.id == widget.note.notebook.target?.id
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 73, 133),
                          ),
                          label: Text(
                            semanticsLabel: noteBook.name,
                            noteBook.name,
                            style: TextStyle(
                              color:
                                  noteBook.id == widget.note.notebook.target?.id
                                      ? Colors.white
                                      : const Color.fromARGB(255, 0, 73, 133),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor:
                                noteBook.id == widget.note.notebook.target?.id
                                    ? const Color.fromARGB(255, 0, 73, 133)
                                    : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void searchNoteBook(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all tags
      context
          .read<NotesProvider>()
          .setSearchedNoteBooks(context.read<NotesProvider>().noteBooks);
    } else {
      // search tags based on the query
      final suggestions =
          context.read<NotesProvider>().noteBooks.where((noteBook) {
        return noteBook.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      context.read<NotesProvider>().setSearchedNoteBooks(suggestions);
    }
  }
}