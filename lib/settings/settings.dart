import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/settings/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: size.width,
            height: size.height,
            // color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Consumer<QuranSettings>(
                builder: (_, state, child) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _showTranslation(state),
                        _divider(),
                        // _enableDarkMode(state, context),
                        // _divider(),
                        _quranFontsBoxes(state),
                        _divider(),
                        _translationFontsBoxes(state),
                        _divider(),
                        _changeFontSize(state),
                        _divider(),
                        _quranThemesBoxes(state),
                        SizedBox(
                          height: 100.0,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Divider _divider() {
    return Divider(
      thickness: 2,
    );
  }

  Column _changeFontSize(QuranSettings state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _settingHeaders('Quran font-size'),
        _arFontSize(state),
        _divider(),
        _settingHeaders('Translation font-size'),
        _translationFontSize(state)
      ],
    );
  }

  Center _arFontSize(QuranSettings state) {
    return Center(
      child: FittedBox(
        child: Row(
          children: [
            Text(
              'الْحَمْدُ لِلَّهِ ',
              style: TextStyle(
                  fontSize: state.arFontSize ?? 23,
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontFamily: state.arFont ?? 'uthmani'),
            ),
            _addAndMinusArFontSize(state)
          ],
        ),
      ),
    );
  }

  Center _translationFontSize(QuranSettings state) {
    return Center(
      child: FittedBox(
        child: Row(
          children: [
            Text(
              'Alhamdulillah ',
              style: state.translationFont != null
                  ? GoogleFonts.getFont(state.translationFont)
                      .copyWith(fontSize: state.translationFontSize)
                  : TextStyle(fontSize: state.translationFontSize ?? 14),
            ),
            _addAndMinusTranslationFontSize(state)
          ],
        ),
      ),
    );
  }

  _addAndMinusTranslationFontSize(QuranSettings state) {
    return Column(
      children: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: state.translationFontSize <= 80.0
                ? () async {
                    state.setTranslationFontSize =
                        state.translationFontSize + 2.0;
                    await setTranslationFontSize(state.translationFontSize);
                  }
                : null),
        Text(state.translationFontSize.toString()),
        IconButton(
            icon: Icon(Icons.remove),
            onPressed: state.translationFontSize >= 10.0
                ? () async {
                    state.setTranslationFontSize =
                        state.translationFontSize - 2.0;
                    await setTranslationFontSize(state.translationFontSize);
                  }
                : null),
      ],
    );
  }

  _addAndMinusArFontSize(QuranSettings state) {
    return Column(
      children: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: state.arFontSize <= 80.0
                ? () async {
                    state.setArFontSize = state.arFontSize + 2.0;
                    await setArFontSize(state.arFontSize);
                  }
                : null),
        Text(state.arFontSize.toString()),
        IconButton(
            icon: Icon(Icons.remove),
            onPressed: state.arFontSize >= 14.0
                ? () async {
                    state.setArFontSize = state.arFontSize - 2.0;
                    await setArFontSize(state.arFontSize);
                  }
                : null),
      ],
    );
  }

  Column _quranFontsBoxes(QuranSettings state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _settingHeaders('Qur\'an font'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _setArFontWidget(state, null, 'none'),
              _setArFontWidget(state, 'amiri', 'Amiri Block'),
              _setArFontWidget(state, 'AmiriLetters', 'Amiri No Diacritics'),
              _setArFontWidget(state, 'AmiriRegular', 'Amiri Regular'),
              _setArFontWidget(state, 'AmiriSlanted', 'Amiri Slanted'),
              _setArFontWidget(state, 'AmiriQuran', 'Amiri Qur\'an'),
              _setArFontWidget(state, 'uthmani', 'Uthmani'),
              _setArFontWidget(state, 'pdmssaleem', 'PDMS Saleem'),
              _setArFontWidget(state, 'reemkufi', 'Reem Kufi'),
              _setArFontWidget(state, 'droid', 'Droid Naskh'),
              _setArFontWidget(state, 'DroidKufiRegular', 'Droid Kufi'),
              _setArFontWidget(state, 'me', 'Me Qur\'an')
            ],
          ),
        ),
      ],
    );
  }

  Column _translationFontsBoxes(QuranSettings state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _settingHeaders('Translation font'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'Roboto'),
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'Cookie'),
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'Pacifico'),
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'Lato'),
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'Oswald'),
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'Space Mono'),
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'Cormorant'),
              _setTranslationFontWidget(
                  state: state, translationFontStyle: 'BioRhyme'),
            ],
          ),
        ),
      ],
    );
  }

  bool _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark;
  }

  _enableDarkMode(QuranSettings state, BuildContext context) {
    return Row(
      children: [
        _settingHeaders('Dark Mode'),
        Checkbox(
            value: _checkIfDarkModeEnabled(),
            onChanged: (show) async {
              state.setShowTranslation = show;
              await setShowTranslation(show);
            })
      ],
    );
  }

  _showTranslation(QuranSettings state) {
    return Row(
      children: [
        _settingHeaders('Show translation'),
        Checkbox(
            value: state.showTranslation ?? true,
            onChanged: (show) async {
              state.setShowTranslation = show;
              await setShowTranslation(show);
            })
      ],
    );
  }

  _setArFontWidget(QuranSettings state, String font, String name) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          state.setArFont = font;
          await setArFont(font);
        },
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 12.0),
            ),
            _selectBox(
                state: state,
                fontType: 'ar',
                displayText: 'الْحَمْدُ لِلَّهِ ',
                arFontFamily: font),
          ],
        ),
      ),
    );
  }

  _setTranslationFontWidget(
      {QuranSettings state, String translationFontStyle}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          state.setTranslationFont = translationFontStyle;
          await setTranslationFont(translationFontStyle);
        },
        child: Column(
          children: [
            Text(
              translationFontStyle,
              style: TextStyle(fontSize: 12.0),
            ),
            _selectBox(
              state: state,
              fontType: 'translation',
              displayText: ' Alhamdulillah ',
              translationFontStyle: translationFontStyle,
            ),
          ],
        ),
      ),
    );
  }

  Container _selectBox(
      {QuranSettings state,
      String fontType,
      String displayText,
      String arFontFamily,
      String translationFontStyle}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
            color: fontType == 'ar'
                ? state.arFont == arFontFamily
                    ? Colors.green
                    : Colors.black45
                : state.translationFont == translationFontStyle
                    ? Colors.green
                    : Colors.black45,
            width: 5.0),
        borderRadius: BorderRadius.circular(10.0),
        image: state.paperTheme != null
            ? DecorationImage(
                image: AssetImage('assets/papers/${state.paperTheme}'),
                fit: BoxFit.cover)
            : null,
      ),
      child: Center(
        child: Text(displayText,
            style: fontType == 'ar'
                ? TextStyle(
                    fontSize: 20.0,
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                    fontFamily: arFontFamily)
                : GoogleFonts.getFont(translationFontStyle)
                    .copyWith(fontSize: 20.0)),
      ),
    );
  }

  Column _quranThemesBoxes(QuranSettings state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _settingHeaders('Themes'),
        _paperThemeNote(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _setThemeWidget(state, null),
              _setThemeWidget(state, '1.jpg'),
              _setThemeWidget(state, '2.jpg'),
              _setThemeWidget(state, '3.jpg'),
              _setThemeWidget(state, '4.jpg'),
              _setThemeWidget(state, '5.png'),
              _setThemeWidget(state, '6.jpg'),
              _setThemeWidget(state, '7.png'),
              _setThemeWidget(state, '8.png'),
              _setThemeWidget(state, '9.png'),
              _setThemeWidget(state, '10.png'),
              _setThemeWidget(state, '11.png'),
              _setThemeWidget(state, '12.jpg'),
              _setThemeWidget(state, '13.jpg'),
              _setThemeWidget(state, '14.jpg'),
              _setThemeWidget(state, '15.png'),
              _setThemeWidget(state, '16.png'),
              _setThemeWidget(state, '17.png')
            ],
          ),
        ),
      ],
    );
  }

  Padding _paperThemeNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
          'Note: Using old paper themes might affect scroll performance and consume more memory'),
    );
  }

  _settingHeaders(String header) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Text(
        header,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  _setThemeWidget(QuranSettings state, String theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
          onTap: () async {
            state.setPaperTheme = theme;
            await setPaperTheme(theme);
          },
          child: _selectThemeBox(state: state, theme: theme)),
    );
  }

  Container _selectThemeBox({
    QuranSettings state,
    String theme,
  }) {
    return Container(
      height: 130,
      width: 300,
      decoration: BoxDecoration(
          border: Border.all(
              color: state.paperTheme == theme ? Colors.green : Colors.black45,
              width: 5.0),
          borderRadius: BorderRadius.circular(10.0),
          image: theme == null
              ? null
              : DecorationImage(
                  image: AssetImage('assets/papers/${theme}'),
                  fit: BoxFit.cover)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيم',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontFamily: state.arFont),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
                'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                style: state.translationFont != null
                    ? GoogleFonts.getFont(state.translationFont)
                        .copyWith(fontSize: 14.0)
                    : TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
