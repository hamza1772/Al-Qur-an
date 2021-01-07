import 'dart:convert';

import 'package:al_quran/juz/juz.dart';
import 'package:flutter/material.dart';

import '../common_widgets.dart';
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
        child: Container(child: juzListBuilder(context)),
      ),
    );
  }

  FutureBuilder<String> juzListBuilder(BuildContext context) {
    return FutureBuilder(
      future:
          DefaultAssetBundle.of(context).loadString('assets/quran/juz.json'),
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
            return juzRangeTile(context, juz, index);
          },
        );
      },
    );
  }

  ListTile juzRangeTile(BuildContext context, List<JuzModel> juz, int index) {
    return ListTile(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Juz(
                    startSurah: juz[index].startSurah,
                    endSurah: juz[index].endSurah,
                    startSurahNum: juz[index].startSurahNum,
                    endSurahNum: juz[index].endSurahNum,
                    startVerse: juz[index].startVerse.substring(6),
                    endVerse: juz[index].endVerse.substring(6),
                    juzNum: juz[index].juzNum,
                  ))),
      leading: surahAndJuzListNumberIcon(index),
      title: juzSurahRange(juz, index),
      subtitle: juzVersesRange(juz, index),
    );
  }

  Text juzVersesRange(List<JuzModel> juz, int index) {
    return Text(' Verse ' +
        juz[index].startVerse.substring(6) +
        ' - Verse ' +
        juz[index].endVerse.substring(6));
  }

  Text juzSurahRange(List<JuzModel> juz, int index) =>
      Text(juz[index].startSurah + ' - ' + juz[index].endSurah);
}
