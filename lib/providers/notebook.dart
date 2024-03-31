import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entities.dart';

class NoteBookProvider extends ChangeNotifier {
  List<NoteBook> _noteBooks = [];

  List<NoteBook> get noteBooks => _noteBooks;

  NoteBookProvider() {
    _init();
  }

  _init() {
    final taskListStream = objectbox.getNoteBooks();
    taskListStream.listen(_onNoteBooksChanged);
  }

  void _onNoteBooksChanged(List<NoteBook> noteBooks) {
    _noteBooks = noteBooks;
    notifyListeners();
  }
}
