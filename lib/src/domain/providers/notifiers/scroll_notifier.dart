// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class ScrollNotifier extends ChangeNotifier {
  /// pageview controller initial page
  int _initialPage = 0;
  // get the current initial page
  int get initialPage => _initialPage;
  // update initial page
  set initialPage(int value) {
    _initialPage = value;
    notifyListeners();
  }

  ScrollController _gridController = ScrollController();
  ScrollController get gridController => _gridController;
  set gridController(ScrollController value) {
    _gridController = value;
    notifyListeners();
  }

  PageController _pageController =
      PageController(initialPage: ScrollNotifier().initialPage);
  PageController get pageController => _pageController;
  set pageController(PageController value) {
    _pageController = value;
    notifyListeners();
  }

  ScrollController _activeScrollController = ScrollController();
  ScrollController get activeScrollController => _activeScrollController;
  set activeScrollController(ScrollController value) {
    _activeScrollController = value;
    notifyListeners();
  }

  Drag? _drag;
  Drag? get drag => _drag;
  set drag(Drag? value) {
    _drag = value;
    notifyListeners();
  }

  ScrollNotifier? _scrollNotifier;
  ScrollNotifier? get scrollNotifier => _scrollNotifier;
  set scrollNotifier(ScrollNotifier? scrollNotifier) {
    _scrollNotifier = scrollNotifier;
    notifyListeners();
  }
}
