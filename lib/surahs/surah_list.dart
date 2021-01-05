import 'dart:convert';

import 'package:al_quran/surahs/surah.dart';
import 'package:al_quran/surahs/surahs_model.dart';
import 'package:flutter/material.dart';

class SurahList extends StatelessWidget {
  List<SurahsModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed
        .map<SurahsModel>((json) => new SurahsModel.fromJson(json))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surahs'),
      ),
      body: Center(
        child: Container(
            child: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/quran/surah_list.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            List<SurahsModel> surahs = parseJosn(snapshot.data.toString());

            return ListView.separated(
              itemCount: surahs.length,
              separatorBuilder: (context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(
                    thickness: 2.0,
                  ),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Surah(
                                surah: surahs[index].name,
                                number: (index + 1).toString(),
                              ))),
                  leading: Container(
                    height: 40,
                    width: 40,
                    child: Stack(
                      children: [
                        ImageIcon(
                          AssetImage('assets/ayyah_icon.png'),
                          size: 40,
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Center(child: Text((index + 1).toString()))),
                      ],
                    ),
                  ),
                  title: Text(surahs[index].name),
                  subtitle: Text(surahs[index].type +
                      ' - ' +
                      surahs[index].ayyahs.toString() +
                      " ayahs"),
                  trailing: Text(
                    surahs[index].nameAr,
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                  ),
                );
              },
            );
          },
        )),
      ),
    );
  }
}
