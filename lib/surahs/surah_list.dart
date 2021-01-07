import 'dart:convert';

import 'package:al_quran/common_widgets.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah.dart';
import 'package:al_quran/surahs/surahs_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        child: Consumer<QuranSettings>(
          builder: (_, state, child) {
            return Container(child: surahListBuilder(context, state));
          },
        ),
      ),
    );
  }

  FutureBuilder<String> surahListBuilder(
      BuildContext context, QuranSettings state) {
    return FutureBuilder(
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
            return surahListTiles(context, surahs, index, state);
          },
        );
      },
    );
  }

  ListTile surahListTiles(BuildContext context, List<SurahsModel> surahs,
      int index, QuranSettings state) {
    return ListTile(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Surah(
                    surahEn: surahs[index].name,
                    number: (index + 1).toString(),
                    surahAr: surahs[index].nameAr,
                    ayahCount: surahs[index].ayyahs,
                  ))),
      leading: surahAndJuzListNumberIcon(index),
      title: Text(surahs[index].name),
      subtitle: ayahCount(surahs, index),
      trailing: surahArName(surahs, index, state),
    );
  }

  Text surahArName(List<SurahsModel> surahs, int index, QuranSettings state) {
    return Text(
      surahs[index].nameAr,
      textDirection: TextDirection.rtl,
      style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontFamily: state.arFont ?? 'uthmani',
          fontSize: 25.0),
    );
  }

  Text ayahCount(List<SurahsModel> surahs, int index) {
    return Text(surahs[index].type +
        ' - ' +
        surahs[index].ayyahs.toString() +
        " ayahs");
  }
}
