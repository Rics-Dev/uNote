import 'package:flutter/material.dart';

class DragStateProvider extends ChangeNotifier {
  bool isDragging = false;
  int originalIndex = -1;

  void startDrag(int index) {
    isDragging = true;
    originalIndex = index;
    notifyListeners();
  }

  void endDrag() {
    isDragging = false;
    originalIndex = -1;
    notifyListeners();
  }
}
