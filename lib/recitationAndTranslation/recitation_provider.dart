import 'package:al_quran/recitationAndTranslation/recitation_settings_model.dart';
import 'package:flutter/cupertino.dart';

class RecitationProvider with ChangeNotifier {
  String _selectedLanguage;

  get getSelectedLanguage => _selectedLanguage;

  set setLanguage(String val) {
    _selectedLanguage = val;
    notifyListeners();
  }

  List<LanguageData> _languageList;

  get getLanguageList => _languageList;

  set setLanguageList(List<LanguageData> val) {
    this._languageList = val;
    // notifyListeners();
  }

  String _selectedTranslatorName;

  get getTranslatorName => _selectedTranslatorName;

  set setTranslatorName(String val) {
    _selectedTranslatorName = val;
    notifyListeners();
  }

  List<LanguageData> _selectedLanguageList;

  get getSelectedLanguageList => _selectedLanguageList;

  set setSelectedLanguageList(List<LanguageData> val) {
    this._selectedLanguageList = val;
    // notifyListeners();
  }

  String _translationIdentifier;

  get getTranslationIdentifier => _translationIdentifier;

  set setTranslationIdentifier(String val) {
    _translationIdentifier = val;
    notifyListeners();
  }

  bool _isLoading = false;

  get getLoadingState => _isLoading;

  set setLoadingState(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
