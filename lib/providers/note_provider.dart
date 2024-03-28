import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';
import '../objectbox.g.dart';

class NotesProvider extends ChangeNotifier {
  Box<Note> noteBox = objectbox.noteBox;
  Box<Tag> tagBox = objectbox.tagBox;
  Box<NoteBook> noteBookBox = objectbox.noteBookBox;

  String _selectedView = 'list';

  List<Tag> _tags = [];
  List<Note> _notes = [];
  List<NoteBook> _noteBooks = [];

  String get selectedView => _selectedView;
  List<Tag> get tags => _tags;
  List<Note> get notes => _notes;
  List<NoteBook> get noteBooks => _noteBooks;

  NotesProvider() {
    _init();
  }

  void _init() async {
    final tasksStream = objectbox.getNotes();
    tasksStream.listen(_onNotesChanged);
    final tagsStream = objectbox.getTags();
    tagsStream.listen(_onTagsChanged);
    final taskListStream = objectbox.getNoteBooks();
    taskListStream.listen(_onNoteBooksChanged);
    // notifyListeners();
  }

  void _onTagsChanged(List<Tag> tags) {
    _tags = tags;
    notifyListeners();
  }

  void _onNotesChanged(List<Note> notes) {
    _notes = notes;
    notifyListeners();
  }

  void _onNoteBooksChanged(List<NoteBook> noteBooks) {
    _noteBooks = noteBooks;
    notifyListeners();
  }

  void changeView(String view) {
    if (view == 'list') {
      _selectedView = 'list';
    } else {
      _selectedView = 'grid';
    }
    notifyListeners();
  }

  void addNote(String title, String content) {
    final note = Note(
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    note.notebook.target = noteBookBox.get(1);
    noteBox.put(note);

    // final noteBook = NoteBook(
    //   name: 'Test',
    //   createdAt: DateTime.now(),
    //   updatedAt: DateTime.now(),
    // );

    // noteBookBox.put(noteBook);
  }

  void deleteNote(int id) {
    noteBox.remove(id);
  }

  void addNotebook(NoteBook noteBook) {
    noteBookBox.put(noteBook);
  }

  void deleteNotebook(int id) {
    noteBookBox.remove(id);
  }

  // void remove(Note note) {
  //   _notes.remove(note);
  //   notifyListeners();
  // }
}
