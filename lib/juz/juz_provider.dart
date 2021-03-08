import 'package:flutter/cupertino.dart';

class JuzProvider with ChangeNotifier {
  Future _future;

  get getFutureValue => _future;

  set setFutureValue(Future val) {
    _future = val;
    notifyListeners();
  }

  String _translationIdentifier;

  get getTranslationIdentifier => _translationIdentifier;

  set setTranslationIdentifier(String val) {
    _translationIdentifier = val;
    notifyListeners();
  }
}
