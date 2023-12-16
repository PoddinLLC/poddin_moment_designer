import 'package:flutter/material.dart';

class GradientNotifier extends ChangeNotifier {
  Color _color1 = const Color.fromARGB(0, 0, 0, 0);
  Color get color1 => _color1;
  set color1(Color color) {
    _color1 = color;
    notifyListeners();
  }

  Color _color2 = const Color.fromARGB(0, 0, 0, 0);
  Color get color2 => _color2;
  set color2(Color color) {
    _color2 = color;
    notifyListeners();
  }
}
