import 'dart:convert';

import 'package:al_quran/LanguageLocal.dart';
import 'package:al_quran/recitationAndTranslation/recitation_provider.dart';
import 'package:al_quran/recitationAndTranslation/recitation_settings_model.dart';
import 'package:al_quran/settings/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RecitationSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<RecitationProvider>(
            create: (context) => RecitationProvider(),
          ),
        ],
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Settings"),
            ),
            body: Consumer<RecitationProvider>(
              builder: (BuildContext context, state, Widget child) {
                if (state.getSelectedLanguage != null &&
                    state.getLanguageList != null) {
                  _getMuftName(
                      state.getSelectedLanguage, state.getLanguageList, state);
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Translation Language",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FutureBuilder(
                          future: _getEdition(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return CircularProgressIndicator();

                            state.setLanguageList = snapshot.data;

                            List<String> list = snapshot.data
                                .map<String>((languageData) {
                                  if (languageData.type == "translation" &&
                                      languageData.format == "text") {
                                    return languageData.language.toString();
                                  }
                                })
                                .toSet()
                                .toList();

                            list.removeWhere((element) => element == null);

                            /*List<String> list = snapshot.data
                                .map<String>((languageData) =>
                                    languageData.language.toString())
                                .toSet()
                                .toList();*/

                            return DropdownButton<String>(
                                hint: Text("Please choose an option"),
                                isExpanded: true,
                                value: state.getSelectedLanguage,
                                onChanged: (newValue) {
                                  state.setLanguage = newValue;
                                  state.setTranslatorName = null;
                                },
                                items: list.map<DropdownMenuItem<String>>((fc) {
                                  return DropdownMenuItem<String>(
                                    child: Text(
                                        LanguageLocal.getDisplayLanguage(fc),
                                        overflow: TextOverflow.ellipsis),
                                    value: fc,
                                  );
                                }).toList());
                          }),
                      Visibility(
                        visible: state.getLanguageList != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Translator name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      FutureBuilder(
                        future: _getSelectedLanguageList(state),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (!snapshot.hasData) return Container();
                          print("recitor val ${state.getTranslatorName}");
                          return DropdownButton<String>(
                            isExpanded: true,
                            hint: Text("Please choose an option"),
                            value: state.getTranslatorName,
                            items: state.getSelectedLanguageList
                                .map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value.name,
                                child: new Text(value.name,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              state.setTranslatorName = val;
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text("Translator set to $val"),
                              ));
                              _setTranslationLanguage(
                                  val, state.getSelectedLanguageList, state);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  _setTranslationLanguage(String val,
      List<LanguageData> getSelectedLanguageList, RecitationProvider state) {
    getSelectedLanguageList.where((element) => element.name == val);
    var identifier = getSelectedLanguageList[0].identifier;
    state.setTranslationIdentifier = identifier;
    setTranslationIdentifier(identifier);
    setTranslationDirection(getSelectedLanguageList[0].direction);
  }

  Future<List<LanguageData>> _getSelectedLanguageList(
      RecitationProvider state) async {
    return await state.getSelectedLanguageList;
  }

  _getMuftName(
    String selectedLanguage,
    List<LanguageData> getLanguageList,
    RecitationProvider state,
  ) async {
    List<LanguageData> list = [];

    getLanguageList.forEach((element) {
      if (element.language == selectedLanguage &&
          element.type == "translation" &&
          element.format == "text") {
        list.add(element);
      }
    });

    state.setSelectedLanguageList = list;
  }

  _getEdition() async {
    var response = await http.get("http://api.alquran.cloud/v1/edition");
    if (response.statusCode == 200) {
      return parseUrlJosn(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  List<LanguageData> parseUrlJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response);
    List<LanguageData> languageList =
        new RecitationSettingsModel.fromJson(parsed).data;

    return languageList;
  }
}
/*
* child: DropdownButton<String>(
                    hint: Text("Please choose an option"),
                    value: state.getSelectedLanguage,
                    items: <String>['A', 'B', 'C', 'D'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      state.setLanguage = val;
                    },
                  ),*/
