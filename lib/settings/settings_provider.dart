import 'package:al_quran/surahs/surahs_model.dart';
import 'package:flutter/cupertino.dart';

class QuranSettings with ChangeNotifier {
  bool _showTranslation;
  String _arFont;
  String _translationFont;
  double _arFontSize;
  double _translationFontSize;
  String _paperTheme;

  String get paperTheme => _paperTheme;

  set setPaperTheme(String value) {
    _paperTheme = value;
    notifyListeners();
  }

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

  get arFont => _arFont;

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

  bool _isSearching = false;

  bool get isSearching => _isSearching;

  set setIsSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  List<SurahsModel> _surahsList = [];

  List<SurahsModel> get getSurahsModelList => _surahsList;

  set setSurahsModelList(List<SurahsModel> value) {
    _surahsList = value;
  }

  List<SurahsModel> _searchResult = [];

  List<SurahsModel> get getSearchResult => _searchResult;

  void clearSearchResult() {
    _searchResult.clear();
    notifyListeners();
  }

  void setSearchResult(SurahsModel value) {
    _searchResult.add(value);
    notifyListeners();
  }
}
