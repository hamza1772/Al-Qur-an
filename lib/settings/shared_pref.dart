import 'package:shared_preferences/shared_preferences.dart';

setShowTranslation(bool show) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('showTranslation', show);
}

setArFont(String font) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('QuranFont', font);
}

setTranslationFont(String font) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('translationFont', font);
}

setArFontSize(double fontSize) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('arFontSize', fontSize);
}

setTranslationFontSize(double fontSize) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('translationFontSize', fontSize);
}

setPaperTheme(String theme) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('paperTheme', theme);
}

setTranslationIdentifier(String identifier) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('translationIdentifier', identifier);
}

setTranslationDirection(String direction) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('translationDirection', direction);
}

getTranslationDirection() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('translationDirection') ?? "rtl";
}
