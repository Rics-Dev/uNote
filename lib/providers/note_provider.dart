import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';
import '../objectbox.g.dart';
import 'task_provider.dart';

class NotesProvider extends ChangeNotifier {
  Box<Note> noteBox = objectbox.noteBox;
  Box<Tag> tagBox = objectbox.tagBox;
  Box<NoteBook> noteBookBox = objectbox.noteBookBox;
  bool _isSearchingNotes = false;
  int _selectedNoteBook = 0;
  List<Note> _sortedNotes = [];
  List<NoteBook> _searchedNoteBooks = [];

  Note _newNote = Note(
      title: '',
      content: '',
      json: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now());

  TasksProvider tasksProvider = TasksProvider();
  bool oldToNew = TasksProvider().oldToNew;

  String _selectedView = 'list';
  List<Note> _notes = [];
  List<NoteBook> _noteBooks = [];

  List<Note> _searchedNotes = [];


    List<Tag> _tags = [];
  final List<Tag> _temporarilyAddedTags = [];
  final List<Tag> _searchedTags = [];
  final List<Tag> _selectedTags = [];




  String get selectedView => _selectedView;
  List<Note> get notes => _notes;
  List<NoteBook> get noteBooks => _noteBooks;
  List<Note> get searchedNotes => _searchedNotes;
  List<Note> get sortedNotes => _sortedNotes;
  bool get isSearchingNotes => _isSearchingNotes;
  int get selectedNoteBook => _selectedNoteBook;
  List<NoteBook> get searchedNoteBooks => _searchedNoteBooks;
  Note get newNote => _newNote;


  List<Tag> get tags => _tags;
  List<Tag> get selectedTags => _selectedTags;
  List<Tag> get temporarilyAddedTags => _temporarilyAddedTags;
  List<Tag> get searchedTags => _searchedTags;


  NotesProvider() {
    _init();
  }

  void _init() async {
    // tagBox.put(Tag(name: 'jsp'));
    // noteBox.removeAll();
    // noteBookBox.removeAll();
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
    _searchedNoteBooks = noteBooks;
    notifyListeners();
  }

  Note? getNoteById(int noteId) {
    // return notes.firstWhere((note) => note.id == noteId);
    final note = noteBox.get(noteId);
    return note;
  }

  void changeView(String view) {
    switch (view) {
      case 'list':
        _selectedView = 'list';
        break;
      case 'compactList':
        _selectedView = 'compactList';
        break;
      case 'grid':
        _selectedView = 'grid';
        break;

      default:
        _selectedView = 'list';
    }
    notifyListeners();
  }

  void addNote(String title, String content, String json, bool isSecured,
      bool isFavorite, int selectedNoteBook) {
    _newNote.title = title;
    _newNote.content = content;
    _newNote.json = json;
    _newNote.isSecured = isSecured;
    _newNote.isFavorite = isFavorite;
    _newNote.createdAt = DateTime.now();
    _newNote.updatedAt = DateTime.now();

    if (_newNote.isSecured) {
      _newNote.notebook.target = null;
    }

    noteBox.put(_newNote);

    _newNote = Note(
        title: '',
        content: '',
        json: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  void addNoteToNoteBook(int noteBookId, int noteId) {
    final noteBook = noteBookBox.get(noteBookId);

    //if new note
    if (noteId == 0) {
      if (newNote.notebook.target?.id == noteBook?.id) {
        _newNote.notebook.target = null;
      } else {
        _newNote.notebook.target = noteBook;
      }
      notifyListeners();
    } else {
      //if existing note
      final note = noteBox.get(noteId);
      if (note != null) {
        if (note.notebook.target?.id == noteBook?.id) {
          note.notebook.target = null;
          noteBox.put(note);
        } else {
          note.notebook.target = noteBook;
          noteBox.put(note);
        }
        notifyListeners();
      }
    }
  }

  void updateNote(int noteId, String title, String content, String json,
      int selectedNoteBookIndex) {
    final updatedNote = noteBox.get(noteId);
    if (updatedNote != null) {
      updatedNote.title = title;
      updatedNote.content = content;
      updatedNote.json = json;
      updatedNote.updatedAt = DateTime.now();

      noteBox.put(updatedNote);
      notifyListeners();
    }
  }

  void updateSecuredNote(int id) {
    final note = noteBox.get(id);
    if (note != null) {
      note.isSecured = !note.isSecured;
      note.notebook.target = null;
      noteBox.put(note);
      notifyListeners();
    }
  }

  void updateFavoriteNote(int id) {
    final note = noteBox.get(id);
    if (note != null) {
      note.isFavorite = !note.isFavorite;
      noteBox.put(note);
      notifyListeners();
    }
  }

  void deleteNote(int id) {
    noteBox.remove(id);
  }

  int addNotebook(NoteBook noteBook) {
    noteBookBox.put(noteBook);
    final noteBookId = noteBookBox.query().build().find().last.id;
    return noteBookId;
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
    List<Note> notesToSort = sortedNotes.isNotEmpty ? sortedNotes : notes;

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

    if (sortedNotes.isNotEmpty) {
      _sortedNotes = notesToSort;
    } else {
      _notes = notesToSort;
    }

    notifyListeners();
  }

  int sortByDate(DateTime a, DateTime b) {
    return tasksProvider.oldToNew ? a.compareTo(b) : b.compareTo(a);
  }

  void setSearchedNoteBooks(List<NoteBook> noteBooks) {
    _searchedNoteBooks = noteBooks;
    notifyListeners();
  }

    void toggleTagSelection(Tag tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    // if (selectedTags.isEmpty) {
    //   _filteredTasks.clear();
    // }
    // filterTasksByTags(selectedTags);
    notifyListeners();
  }

    //Done
  void clearSelectedTags() {
    _selectedTags.clear();
    notifyListeners();
  }
}
