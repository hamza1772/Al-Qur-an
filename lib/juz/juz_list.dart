import 'dart:convert';

import 'package:flutter/material.dart';

import 'juz_model.dart';

class JuzList extends StatelessWidget {
  List<JuzModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed.map<JuzModel>((json) => new JuzModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juz'),
      ),
      body: Center(
        child: Container(
            child: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/quran/juz.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            print(snapshot.data);

            List<JuzModel> juz = parseJosn(snapshot.data.toString());

            return ListView.separated(
              itemCount: juz.length,
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
                  title:
                      Text(juz[index].startSurah + ' - ' + juz[index].endSurah),
                  subtitle: Text(' Verse ' +
                      juz[index].startVerse.substring(6) +
                      ' - Verse ' +
                      juz[index].endVerse.substring(6)),
                );
              },
            );
          },
        )),
      ),
    );
  }
}
