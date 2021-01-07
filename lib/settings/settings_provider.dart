import 'package:flutter/cupertino.dart';

class QuranSettings with ChangeNotifier {
  bool _showTranslation;
  String _arFont;
  String _translationFont;
  double _arFontSize;
  double _translationFontSize;

  bool get showTranslation => _showTranslation;

  set setShowTranslation(bool value) {
    _showTranslation = value;
    notifyListeners();
  }

  get translationFont => _translationFont;

  set setTranslationFont(String value) {
    _translationFont = value;
    notifyListeners();
  }

  String get arFont => _arFont;

  set setArFont(String valueString) {
    _arFont = valueString;
    notifyListeners();
  }

  double get arFontSize => _arFontSize;

  set setArFontSize(double value) {
    _arFontSize = value;
    notifyListeners();
  }

  double get translationFontSize => _translationFontSize;

  set setTranslationFontSize(double value) {
    _translationFontSize = value;
    notifyListeners();
  }
}
