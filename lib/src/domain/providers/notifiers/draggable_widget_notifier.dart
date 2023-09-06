import 'package:flutter/material.dart';
// import 'package:modal_gif_picker/modal_gif_picker.dart';
import 'package:poddin_moment_designer/src/domain/models/editable_items.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';

class DraggableWidgetNotifier extends ChangeNotifier {
  List<EditableItem> _draggableWidget = [];
  List<EditableItem> get draggableWidget => _draggableWidget;
  set draggableWidget(List<EditableItem> item) {
    _draggableWidget = item;
    notifyListeners();
  }

  /// Uploaded Pictures
  int _uploadedMedia = 0;
  // current uploaded pictures length
  int get uploadedMedia => _uploadedMedia;
  // get uploaded pictures length
  set uploadedMedia(int index) {
    // set new length
    if (index < 1) {
      _uploadedMedia -= 1;
      notifyListeners();
    } else {
      _uploadedMedia += 1;
      notifyListeners();
    }
  }

  // GiphyGif? _gif;
  // GiphyGif? get giphy => _gif;
  // set giphy(GiphyGif? giphy) {
  //   _gif = giphy;
  //   notifyListeners();
  // }

  setDefaults() {
    _draggableWidget = [];
    _uploadedMedia = 0;
  }

  clearMediaPath(ControlNotifier notifier) {
    var path = notifier.mediaPath;
    if (_uploadedMedia > 1 && path.isNotEmpty) {
      notifier.mediaPath = '';
      notifier.gradientIndex += 1;
    }
  }
}
