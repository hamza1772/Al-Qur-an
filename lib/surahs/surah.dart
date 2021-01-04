import 'dart:convert';

import 'package:al_quran/surahs/surah_model.dart';
import 'package:flutter/material.dart';

class Surah extends StatelessWidget {
  final String surah;
  final String number;

  Surah({this.surah, this.number});

  Map<String, dynamic> parseJosn(String response) {
    if (response == null) {
      return {};
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed.map<SurahModel>((json) => new SurahModel.fromJson(json));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(surah.toString()),
      ),
      body: Center(
        child: Container(
            child: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/quran/surah/surah_$number.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            print(snapshot.data);

            Map<String, dynamic> surah = parseJosn(snapshot.data.toString());

            return ListView.separated(
              itemCount: surah['verse'].length,
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
                  title: Text(surah['verse']['verse_$index']),
                );
              },
            );
          },
        )),
      ),
    );
  }
}
