import 'package:flutter/material.dart';

class NotesProvider extends ChangeNotifier {
  String _selectedView = 'list';

  String get selectedView => _selectedView;

  void changeView(String view) {
    if (view == 'list') {
      _selectedView = 'list';
    } else {
      _selectedView = 'grid';
    }
    notifyListeners();
  }

  // List<Note> _notes = [];

  // List<Note> get notes => _notes;

  // void add(Note note) {
  //   _notes.add(note);
  //   notifyListeners();
  // }

  // void remove(Note note) {
  //   _notes.remove(note);
  //   notifyListeners();
  // }
}