import 'package:al_quran/juz/juz_provider.dart';
import 'package:al_quran/recitationAndTranslation/recitation_settings.dart';
import 'package:al_quran/settings/settings.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

Padding tileDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Divider(
      thickness: 2.0,
      // thikness
    ),
  );
}

ayahNumber(String ayahNum, QuranSettings state) {
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
            child: Text(
              ayahNum,
              style: state.translationFont != null ? GoogleFonts.getFont(state.translationFont) : TextStyle(),
            ),
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
          fontSize: state.arFontSize ?? 23,
          color: Colors.green.shade900,
          fontWeight: FontWeight.bold,
          fontFamily: state.arFont ?? 'uthmani'),
    ),
  );
}

ayahTlle(int index, List<SurahModel> surahs) {
  return Consumer<QuranSettings>(
    builder: (_, state, child) {
      return Container(
        decoration: state.paperTheme != null
            ? BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/papers/${state.paperTheme}'), fit: BoxFit.fill),
              )
            : null,
        child: ListTile(
          leading: ayahNumber(surahs[index].verse_number.toString(), state),
          title: ayah(surahs, index, state),
          subtitle: state.showTranslation == null || state.showTranslation == true
              ? Text(
                  surahs[index].translation,
                  style: state.translationFont != null
                      ? GoogleFonts.getFont(state.translationFont).copyWith(fontSize: state.translationFontSize)
                      : TextStyle(
                          fontSize: state.translationFontSize,
                        ),
                  textDirection: surahs[index].translationDirection == "rtl" ? TextDirection.rtl : TextDirection.ltr,
                  /*textDirection: getTranslationDirection() == "rtl"
                          ? TextDirection.rtl
                          : TextDirection.ltr,*/
                )
              : SizedBox.shrink(),
        ),
      );
    },
  );
}

basmalaTile(BuildContext context) {
  return Consumer<QuranSettings>(
    builder: (_, state, child) {
      return Container(
        decoration: state.paperTheme != null
            ? BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/papers/${state.paperTheme}'), fit: BoxFit.cover),
              )
            : null,
        child: Padding(
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
        ),
      );
    },
  );
}

Container surahAndJuzListNumberIcon(int index, QuranSettings state) {
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
          child: Center(
            child: Text(
              (index + 1).toString(),
              style: state.translationFont != null
                  ? GoogleFonts.getFont(state.translationFont)
                  : TextStyle(fontSize: state.translationFontSize ?? 14),
            ),
          ),
        ),
      ],
    ),
  );
}

juzAyahs(
  List<SurahModel> surahs, ItemScrollController itemScrollController,
  // JuzProvider state,
) {
  return Consumer<JuzProvider>(
    builder: (context, state, child) {
      return ScrollablePositionedList.builder(
        itemCount: surahs.length,
        itemScrollController: itemScrollController,
        itemBuilder: (BuildContext context, int index) {
          return state.getCurrentIndex == index
              ? Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.6)),
                  child: showJuzAyahs(context, index, surahs,state,itemScrollController))
              : showJuzAyahs(context, index, surahs,state,itemScrollController);
        },
      );
    },
  );
}

showJuzAyahs(context, index, surahs,JuzProvider state,itemScrollController) {
  return InkWell(
    onTap: () {
      state.setCurrentIndex = index;
      state.shouldPlayNext = true;
      state.logInController = index;
      itemScrollController.jumpTo(
        index: index,
      );
    },
    child: Container(
      child: index == 0 && surahs[index].surah_number != 1 && surahs[index].surah_number != 9
          ? Column(
        children: [basmalaTile(context), ayahTlle(index, surahs)],
      )
          : ayahTlle(index, surahs),
    ),
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

IconButton recitationTranslationNav(BuildContext context) {
  return IconButton(
    icon: Icon(Icons.menu_book_rounded),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecitationSetting(),
      ),
    ),
  );
}
