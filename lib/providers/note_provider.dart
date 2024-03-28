import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';
import '../objectbox.g.dart';

class NotesProvider extends ChangeNotifier {
  Box<Note> noteBox = objectbox.noteBox;
  Box<Tag> tagBox = objectbox.tagBox;
  Box<NoteBook> noteBookBox = objectbox.noteBookBox;
  bool _isSearchingNotes = false;

  String _selectedView = 'list';

  List<Tag> _tags = [];
  List<Note> _notes = [];
  List<NoteBook> _noteBooks = [];

  List<Note> _searchedNotes = [];

  String get selectedView => _selectedView;
  List<Tag> get tags => _tags;
  List<Note> get notes => _notes;
  List<NoteBook> get noteBooks => _noteBooks;
  List<Note> get searchedNotes => _searchedNotes;
  bool get isSearchingNotes => _isSearchingNotes;

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
    _notes = notes.reversed.toList();
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
    noteBox.put(note);

    // note.notebook.target = noteBookBox.get(2);

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

  void setIsSearching(bool bool) {
    _isSearchingNotes = bool;
    notifyListeners();
  }

  void setSearchedNotes(List<Note> suggestions) {
    _isSearchingNotes = true;
    if (suggestions.isEmpty) {
      _searchedNotes.clear();
    }
    _searchedNotes = suggestions;
    notifyListeners();
  }
}
