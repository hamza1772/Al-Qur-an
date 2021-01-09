import 'dart:convert';

import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../common_widgets.dart';

class Surah extends StatelessWidget {
  final String surahEn;
  final String surahAr;
  final String number;
  final int ayahCount;

  Surah({this.surahEn, this.number, this.surahAr, this.ayahCount});

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  List<SurahModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed
        .map<SurahModel>((json) => new SurahModel.fromJson(json))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print(surahEn);
    print(number);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace:
            FlexibleSpaceBar(centerTitle: true, title: _surahAppbar(context)),
        actions: [
          settingsNav(context),
        ],
      ),
      body: Center(
        child: Consumer<QuranSettings>(
          builder: (_, state, child) {
            return Container(
              decoration: state.paperTheme != null
                  ? BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage('assets/papers/${state.paperTheme}'),
                          fit: BoxFit.cover),
                    )
                  : null,
              child: buildSurah(context),
            );
          },
        ),
      ),
    );
  }

  SafeArea _surahAppbar(BuildContext context) {
    return SafeArea(
      child: Consumer<QuranSettings>(
        builder: (_, state, child) {
          return GestureDetector(
            onTap: () {
              _showModalBottomSheet(
                  context: context,
                  surah: surahEn,
                  ayahCount: ayahCount,
                  itemScrollController: itemScrollController);
            },
            child: _appbarSurahName(state),
          );
        },
      ),
    );
  }

  FittedBox _appbarSurahName(QuranSettings state) {
    return FittedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _appbarSurahEnName(state),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
            ],
          ),
          _appBarSurahArName(),
        ],
      ),
    );
  }

  Text _appbarSurahEnName(QuranSettings state) {
    return Text(
      surahEn.toString(),
      style: state.translationFont != null
          ? GoogleFonts.getFont(state.translationFont)
          : TextStyle(fontSize: state.translationFontSize ?? 16),
    );
  }

  Text _appBarSurahArName() {
    return Text(
      surahAr,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  FutureBuilder<String> buildSurah(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/quran/en.pretty.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        // print(snapshot.data);

        List<SurahModel> surahs = parseJosn(snapshot.data.toString())
            .where((element) => element.surah_number == int.parse(number))
            .toList();
        print(surahs.length);

        return surahAyahs(surahs);
      },
    );
  }

  surahAyahs(List<SurahModel> surahs) {
    return ScrollablePositionedList.builder(
      itemCount: surahs.length,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
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
}

class _BottomSheetContent extends StatelessWidget {
  final String surah;
  final int ayahCount;
  final ItemScrollController itemScrollController;
  _BottomSheetContent({this.surah, this.ayahCount, this.itemScrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        child: Column(
          children: [
            _bottomSheetHeader(),
            const Divider(thickness: 1),
            _bottomSheetAyahList(),
          ],
        ),
      ),
    );
  }

  Container _bottomSheetHeader() {
    return Container(
      height: 70,
      child: Center(
        child: Text(
          surah,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Expanded _bottomSheetAyahList() {
    return Expanded(
      child: ListView.builder(
        itemCount: ayahCount,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              itemScrollController.jumpTo(
                index: index,
                //   duration: Duration(seconds: 2),
                //curve: Curves.easeInOutCubic,
              );
              Navigator.pop(context);
            },
            title: Text('Ayah ${index + 1}'),
          );
        },
      ),
    );
  }
}

void _showModalBottomSheet(
    {BuildContext context,
    String surah,
    int ayahCount,
    ItemScrollController itemScrollController}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return _BottomSheetContent(
          surah: surah,
          ayahCount: ayahCount,
          itemScrollController: itemScrollController);
    },
  );
}
