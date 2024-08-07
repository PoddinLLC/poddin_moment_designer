// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';
// import 'package:modal_gif_picker/modal_gif_picker.dart';
import 'package:poddin_moment_designer/src/domain/models/editable_items.dart';

class DraggableWidgetNotifier extends ChangeNotifier {
  List<EditableItem> _draggableWidget = [];
  List<EditableItem> get draggableWidget => _draggableWidget;
  set draggableWidget(List<EditableItem> item) {
    _draggableWidget = item;
    // notifyListeners();
  }

  /// Insert item at [index]
  insertAt(int index, EditableItem element) {
    _draggableWidget.insert(index, element);
    notifyListeners();
  }

  /// Remove item at [index] (this reduces length of the list)
  removeAt(int index) {
    _draggableWidget.removeAt(index);
    notifyListeners();
  }

  /// Add [item] to the end of the list
  addItem(EditableItem item) {
    _draggableWidget.add(item);
    notifyListeners();
  }

  /// Remove [item] from the list (this reduces length of the list)
  removeItem(EditableItem item) {
    _draggableWidget.remove(item);
    notifyListeners();
  }

  // GiphyGif? _gif;
  // GiphyGif? get giphy => _gif;
  // set giphy(GiphyGif? giphy) {
  //   _gif = giphy;
  //   notifyListeners();
  // }

  setDefaults() {
    _draggableWidget = [];
  }
}
