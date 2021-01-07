import 'dart:convert';

import 'package:al_quran/surahs/surah_model.dart';
import 'package:flutter/material.dart';

import '../common_widgets.dart';

class Juz extends StatelessWidget {
  final String startSurah;
  final String endSurah;
  final String startSurahNum;
  final String endSurahNum;
  final String juzNum;
  final String startVerse;
  final String endVerse;

  Juz(
      {this.startSurah,
      this.endSurah,
      this.startSurahNum,
      this.endSurahNum,
      this.juzNum,
      this.startVerse,
      this.endVerse});

  List<SurahModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed
        .map<SurahModel>((json) => new SurahModel.fromJson(json))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juz ' + juzNum.toString()),
        actions: [
          settingsNav(context),
        ],
      ),
      body: Center(
        child: Container(child: buildSurah(context)),
      ),
    );
  }

  FutureBuilder<String> buildSurah(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/quran/en.pretty.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        List<SurahModel> surahs =
            parseJosn(snapshot.data.toString()).where((element) {
          if (startSurahNum != endSurahNum) {
            return (element.surah_number == int.parse(startSurahNum) &&
                    element.verse_number >= int.parse(startVerse)) ||
                element.surah_number > int.parse(startSurahNum) &&
                    element.surah_number < int.parse(endSurahNum) ||
                (element.verse_number <= int.parse(endVerse) &&
                    element.surah_number == int.parse(endSurahNum));
          } else {
            return (element.surah_number == int.parse(startSurahNum) &&
                element.verse_number >= int.parse(startVerse) &&
                int.parse(endVerse) >= element.verse_number);
          }
        }).toList();
        return juzAyahs(surahs);
      },
    );
  }
}
