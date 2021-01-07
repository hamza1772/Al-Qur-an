import 'package:al_quran/settings/settings.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Padding tileDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Divider(
      thickness: 2.0,
    ),
  );
}

Container ayahNumber(String ayahNum) {
  return Container(
    height: 45,
    width: 45,
    child: Stack(
      children: [
        ImageIcon(
          AssetImage('assets/ayyah_icon.png'),
          size: 45,
        ),
        Align(
          alignment: Alignment.center,
          child: Center(
            child: Text(ayahNum),
          ),
        ),
      ],
    ),
  );
}

Padding ayah(List<SurahModel> surahs, int index, QuranSettings state) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      surahs[index].text,
      textDirection: TextDirection.rtl,
      style: TextStyle(
          fontSize: state.arFontSize ?? 20,
          color: Colors.green.shade900,
          fontFamily: state.arFont ?? 'uthmani'),
    ),
  );
}

ayahTlle(int index, List<SurahModel> surahs) {
  return Consumer<QuranSettings>(
    builder: (_, state, child) {
      return ListTile(
        leading: ayahNumber(surahs[index].verse_number.toString()),
        title: ayah(surahs, index, state),
        subtitle: state.showTranslation == null || state.showTranslation == true
            ? Text(surahs[index].translation)
            : SizedBox.shrink(),
      );
    },
  );
}

Padding basmalaTile(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      child: ImageIcon(
        AssetImage(
          'assets/quran/basmala2.png',
        ),
        size: 50.0,
        color: Colors.green.shade900,
      ),
    ),
  );
}

Container surahAndJuzListNumberIcon(int index) {
  return Container(
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
  );
}

ListView juzAyahs(List<SurahModel> surahs) {
  return ListView.separated(
    itemCount: surahs.length,
    separatorBuilder: (context, int index) {
      return tileDivider();
    },
    itemBuilder: (BuildContext context, int index) {
      return index == 0 &&
              surahs[index].surah_number != 1 &&
              surahs[index].surah_number != 9
          ? Column(
              children: [basmalaTile(context), ayahTlle(index, surahs)],
            )
          : ayahTlle(index, surahs);
    },
  );
}

IconButton settingsNav(BuildContext context) {
  return IconButton(
    icon: Icon(Icons.settings),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Settings(),
      ),
    ),
  );
}
