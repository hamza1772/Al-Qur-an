import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:al_quran/httpService.dart';
import 'package:al_quran/juz/juz_model.dart';
import 'package:al_quran/juz/juz_provider.dart';
import 'package:al_quran/recitationAndTranslation/recitation_settings.dart';
import 'package:al_quran/surahs/surah_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_widgets.dart';
import '../player_widget.dart';
import 'juz_new_model.dart';

List<SurahModel> parseUrlJosn(map) {
  var response = map['val1'];
  var juzNumber = map['val2'];

  if (response == null) {
    return [];
  }

  QuranJuzModel signUpResponse = signUpResponseFromJson(response);

  List<Surah> surahList = signUpResponse.data.surahs;

  List<SurahModel> customList = [];

  surahList.forEach((surahModel) {
    surahModel.ayahs.forEach((element) {
      if (element.juz == juzNumber) {
        customList
            .add(SurahModel(surah_number: surahModel.number, verse_number: element.numberInSurah, translation: element.text));
      }
    });
  });

  return customList;
}

class Juz extends StatelessWidget {
  final String startSurah;
  final String endSurah;
  final String startSurahNum;
  final String endSurahNum;
  final String juzNum;
  final String startVerse;
  final String endVerse;

  Juz(
      {Key key,
      this.startSurah,
      this.endSurah,
      this.startSurahNum,
      this.endSurahNum,
      this.juzNum,
      this.startVerse,
      this.endVerse})
      : super(key: key);

  final ItemScrollController itemScrollController = ItemScrollController();


  List<SurahModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed.map<SurahModel>((json) => new SurahModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    future = getSurah(context);

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('Juz ' + juzNum.toString()),
        actions: [
          Consumer<JuzProvider>(
            builder: (_, state, child) {
              return IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  state.setCurrentIndex = 0;
                },
              );
            },
          ),
          Consumer<JuzProvider>(
            builder: (_, state, child) {
              return IconButton(
                icon: Icon(Icons.menu_book_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecitationSetting(),
                  ),
                ).then((value) {
                  future = getSurah(context);
                }),
              );
            },
          ),
          settingsNav(context),
        ],
      ),
      body: Consumer<JuzProvider>(
        builder: (_, state, child) {
          return Column(
            children: [
              Flexible(child: Container(child: Center(child: buildSurah(context, juzNum)))),
              StreamBuilder(
                stream: controller.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    return PlayerWidget(
                      audioList: snapshot.data.map<String>((SurahModel e) {
                        return e.audio;
                      }).toList(),
                      state: state,
                      itemScrollController: itemScrollController,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String> getTranslationDirection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('translationDirection') ?? "ltr";
  }

  Future<List<dynamic>> getTranslation(number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var identifier = prefs.getString('translationIdentifier') ?? "en.ahmedali";
    var recitationResponse = await _readIdentifier(identifier);
    Map map = Map();
    map['val1'] = recitationResponse;
    map['val2'] = int.parse(number);
    List<SurahModel> list = await compute(parseUrlJosn, map);
    return list;
  }

  Future<String> _readIdentifier(String identifier) async {
    String text;
    try {
      final Directory directory = Platform.isIOS ? await getLibraryDirectory() : await getExternalStorageDirectory();
      final File file = File('${directory.path}/$identifier.json');
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  Future<List<NewAyah>> getJuz() async {
    List<NewAyah> ayahs = await HttpService().getJuzAyah(juzNum);
    return ayahs;
  }

  Future<dynamic> getSurah(var context) async {
    return Future.wait([
      getTranslationDirection(),
      getTranslation(juzNum),
      DefaultAssetBundle.of(context).loadString('assets/quran/en.pretty.json'),
      getJuz()
    ]);
  }

  Future future;
  List<SurahModel> surahs;
  final controller = StreamController<List<SurahModel>>();

  FutureBuilder<dynamic> buildSurah(BuildContext context, String juzNum) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) return CircularProgressIndicator();
        surahs = parseJosn(snapshot.data[2].toString()).where((element) {
          if (startSurahNum != endSurahNum) {
            return (element.surah_number == int.parse(startSurahNum) &&
                    element.verse_number >= int.parse(startVerse)) ||
                element.surah_number > int.parse(startSurahNum) && element.surah_number < int.parse(endSurahNum) ||
                (element.verse_number <= int.parse(endVerse) && element.surah_number == int.parse(endSurahNum));
          } else {
            return (element.surah_number == int.parse(startSurahNum) &&
                element.verse_number >= int.parse(startVerse) &&
                int.parse(endVerse) >= element.verse_number);
          }
        }).toList();

        var translationDirection = snapshot.data[0];
        List<SurahModel> juzSurah = snapshot.data[1];
        List<NewAyah> ayahList = snapshot.data[3];

        surahs.forEach((model) {
          juzSurah.forEach((element) {
            if (element.surah_number == model.surah_number && element.verse_number == model.verse_number) {
              model.translation = element.translation;
              model.translationDirection = translationDirection;
            }
          });

          ayahList.forEach((NewAyah element) {
            if (element.surah.number == model.surah_number && element.numberInSurah == model.verse_number) {
              model.audio = element.audio;
            }
          });
        });

        controller.add(surahs);

        return juzAyahs(surahs, itemScrollController);
      },
    );
  }
}
