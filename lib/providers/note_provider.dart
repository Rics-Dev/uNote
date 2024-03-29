import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';
import '../objectbox.g.dart';
import 'taskProvider.dart';

class NotesProvider extends ChangeNotifier {
  Box<Note> noteBox = objectbox.noteBox;
  Box<Tag> tagBox = objectbox.tagBox;
  Box<NoteBook> noteBookBox = objectbox.noteBookBox;
  bool _isSearchingNotes = false;
  int _selectedNoteBook = 0;
  List<Note> _filteredNotes = [];

  TasksProvider tasksProvider = TasksProvider();
  bool oldToNew = TasksProvider().oldToNew;

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
  List<Note> get filteredNotes => _filteredNotes;
  bool get isSearchingNotes => _isSearchingNotes;
  int get selectedNoteBook => _selectedNoteBook;

  NotesProvider() {
    _init();
  }

  void _init() async {
    // noteBox.removeAll();
    // final noteBooks = noteBookBox.getAll();
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

  void addNote(
      String title, String content, String json, int selectedNoteBook) {
    final note = Note(
      title: title,
      content: content,
      json: json,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (selectedNoteBook > 0 && selectedNoteBook < noteBooks.length + 1) {
      final noteBook = noteBooks[selectedNoteBook - 1];
      note.notebook.target = noteBook;
    }
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

  void setSelectedNoteBook(int index) {
    _selectedNoteBook = index;
    notifyListeners();
  }

  //Sort View for notes section

  void toggleNewToOld() {
    tasksProvider.toggleNewToOld();
    sortNotes();
    notifyListeners();
  }

  void toggleSortByCreationDate() {
    tasksProvider.sortCriteria = SortCriteria.creationDate;
    sortNotes();
    notifyListeners();
  }

  void toggleSortByEditionDate() {
    tasksProvider.sortCriteria = SortCriteria.editionDate;
    sortNotes();
    notifyListeners();
  }

  void toggleSortByNameAZ() {
    tasksProvider.sortCriteria = SortCriteria.nameAZ;
    sortNotes();
    notifyListeners();
  }

  void toggleSortByNameZA() {
    tasksProvider.sortCriteria = SortCriteria.nameZA;
    sortNotes();
    notifyListeners();
  }

  void sortNotes() {
    List<Note> notesToSort = filteredNotes.isNotEmpty ? filteredNotes : notes;

    notesToSort.sort((a, b) {
      switch (tasksProvider.sortCriteria) {
        case SortCriteria.creationDate:
          return sortByDate(a.createdAt, b.createdAt);
        case SortCriteria.editionDate:
          return sortByDate(a.updatedAt, b.updatedAt);
        case SortCriteria.nameAZ:
          return a.title.compareTo(b.title);
        case SortCriteria.nameZA:
          return b.title.compareTo(a.title);
        default:
          return 0;
      }
    });

    if (filteredNotes.isNotEmpty) {
      _filteredNotes = notesToSort;
    } else {
      _notes = notesToSort;
    }

    notifyListeners();
  }

  int sortByDate(DateTime a, DateTime b) {
    return tasksProvider.oldToNew ? a.compareTo(b) : b.compareTo(a);
  }
}
