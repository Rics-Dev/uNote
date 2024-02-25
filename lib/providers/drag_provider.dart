import 'package:flutter/material.dart';

class DragStateProvider extends ChangeNotifier {
  bool isDragging = false;

  void startDrag() {
    isDragging = true;
    notifyListeners();
  }

  void endDrag() {
    isDragging = false;
    notifyListeners();
  }
}