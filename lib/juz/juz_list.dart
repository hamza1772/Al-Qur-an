import 'dart:convert';

import 'package:al_quran/juz/juz.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
        child: Consumer<QuranSettings>(
          builder: (_, state, child) {
            return Container(
              child: juzListBuilder(context, state),
            );
          },
        ),
      ),
    );
  }

  FutureBuilder<String> juzListBuilder(BuildContext context, state) {
    return FutureBuilder(
      future:
          DefaultAssetBundle.of(context).loadString('assets/quran/juz.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

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
            return juzRangeTile(context, juz, index, state);
          },
        );
      },
    );
  }

  ListTile juzRangeTile(BuildContext context, List<JuzModel> juz, int index,
      QuranSettings state) {
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
      leading: surahAndJuzListNumberIcon(index, state),
      title: juzSurahRange(juz, index, state),
      subtitle: juzVersesRange(juz, index, state),
    );
  }

  Text juzVersesRange(List<JuzModel> juz, int index, QuranSettings state) {
    return Text(
      ' Verse ' +
          juz[index].startVerse.substring(6) +
          ' - Verse ' +
          juz[index].endVerse.substring(6),
      style: state.translationFont != null
          ? GoogleFonts.getFont(state.translationFont)
          : TextStyle(fontSize: state.translationFontSize ?? 14),
    );
  }

  Text juzSurahRange(List<JuzModel> juz, int index, QuranSettings state) =>
      Text(
        juz[index].startSurah + ' - ' + juz[index].endSurah,
        style: state.translationFont != null
            ? GoogleFonts.getFont(state.translationFont)
            : TextStyle(fontSize: state.translationFontSize ?? 14),
      );
}
