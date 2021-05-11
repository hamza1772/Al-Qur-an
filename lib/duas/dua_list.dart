import 'dart:convert';

import 'package:al_quran/common_widgets.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'dua_model.dart';

class DuaList extends StatelessWidget {
  List<DuaModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed.map<DuaModel>((json) => new DuaModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranSettings>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            brightness: Brightness.dark,
            title: Text(
              'Duas',
              style: state.translationFont != null
                  ? GoogleFonts.getFont(state.translationFont)
                  : TextStyle(),
            ),
            actions: [settingsNav(context)],
          ),
          body: Center(
            child: Container(
                decoration: state.paperTheme != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/papers/${state.paperTheme}'),
                            fit: BoxFit.cover),
                      )
                    : null,
                child: duaListFutureBuilder(context, state)),
          ),
        );
      },
    );
  }

  FutureBuilder<String> duaListFutureBuilder(
      BuildContext context, QuranSettings state) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/quran/dua_list.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        List<DuaModel> dua = parseJosn(snapshot.data.toString());

        return ListView.builder(
          itemCount: dua.length,
          itemBuilder: (BuildContext context, int index) {
            return duaTile(index, dua, state);
          },
        );
      },
    );
  }

  duaTile(int index, List<DuaModel> dua, QuranSettings state) {
    return Consumer<QuranSettings>(
      builder: (_, state, child) {
        return Container(
          decoration: state.paperTheme != null
              ? BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/papers/${state.paperTheme}'),
                      fit: BoxFit.cover),
                )
              : null,
          child: ListTile(
            leading: Container(
              height: 40,
              width: 40,
              child: duaNumberIcon(index, state),
            ),
            title: duaText(dua, index, state),
            subtitle: duaReference(dua, index, state),
          ),
        );
      },
    );
  }

  arText(List<DuaModel> dua, int index, QuranSettings state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        dua[index].dua,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
            fontFamily: state.arFont ?? 'uthmani',
            fontSize: state.arFontSize ?? 23.0),
      ),
    );
  }

  Stack duaNumberIcon(int index, state) {
    return Stack(
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
    );
  }

  Text duaReference(List<DuaModel> dua, int index, QuranSettings state) {
    return Text(
      dua[index].reference,
      textDirection: TextDirection.rtl,
      style: state.translationFont != null
          ? GoogleFonts.getFont(state.translationFont)
              .copyWith(fontSize: state.translationFontSize)
          : TextStyle(fontSize: state.translationFontSize),
    );
  }

  Column duaText(List<DuaModel> dua, int index, QuranSettings state) {
    return Column(
      children: [
        arText(dua, index, state),
        state.showTranslation == null || state.showTranslation == true
            ? Text(
                dua[index].translation,
                style: state.translationFont != null
                    ? GoogleFonts.getFont(state.translationFont)
                        .copyWith(fontSize: state.translationFontSize)
                    : TextStyle(fontSize: state.translationFontSize),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
