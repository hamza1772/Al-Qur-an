import 'dart:async';

import 'package:flutter/cupertino.dart';

class JuzProvider with ChangeNotifier {
  final _dialCodeStreamController = StreamController<int>();

  Stream<int> get dialCodeStream => _dialCodeStreamController.stream;

  Sink<int> get dialCodeSink => _dialCodeStreamController.sink;

  set logInController(updatedDialCode) {
    _dialCodeStreamController.add(updatedDialCode);
  }

  @override
  void removeListener(VoidCallback listener) {
    _dialCodeStreamController.close();
  } //

  String _translationIdentifier;

  get getTranslationIdentifier => _translationIdentifier;

  set setTranslationIdentifier(String val) {
    this._translationIdentifier = val;
    notifyListeners();
  }

  int _currentIndex = 0;

  get getCurrentIndex => _currentIndex;

  set setCurrentIndex(int val) {
    _currentIndex = val;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _currentIndex = 0;
  }

  bool _shouldPlayNext = false;

  get shouldPlayNext => _shouldPlayNext;

  set shouldPlayNext(bool val) {
    this._shouldPlayNext = val;
    notifyListeners();
  }
}
