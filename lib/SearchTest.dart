import 'dart:convert';

import 'package:al_quran/common_widgets.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah.dart';
import 'package:al_quran/surahs/surahs_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchTest extends StatelessWidget {
  List<SurahsModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed
        .map<SurahsModel>((json) => new SurahsModel.fromJson(json))
        .toList();
  }

  TextEditingController _searchQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranSettings>(
      builder: (BuildContext context, state, Widget child) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(),
            title:
                state.isSearching ? _buildSearchField(state) : Text("Surahs"),
            actions: _buildActions(state, context),
          ),
          body:
              Center(child: Container(child: surahListBuilder(context, state))),
        );
      },
    );
  }

  Widget _buildSearchField(QuranSettings state) {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query, state),
    );
  }

  List<Widget> _buildActions(QuranSettings state, BuildContext context) {
    if (state.isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery(state);
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => _startSearch(state, context),
      ),
    ];
  }

  void _startSearch(QuranSettings state, BuildContext context) {
    ModalRoute.of(context).addLocalHistoryEntry(
        LocalHistoryEntry(onRemove: () => _stopSearching(state)));

    state.setIsSearching = true;
  }

  void updateSearchQuery(String newQuery, QuranSettings state) {
    // if (newQuery.isNotEmpty) {}

    state.clearSearchResult();

    if (newQuery.isEmpty) {
      return;
    }

    state.getSurahsModelList.forEach((userDetail) {
      if (userDetail.name.toLowerCase().contains(newQuery.toLowerCase()) ||
          userDetail.nameAr.toLowerCase().contains(newQuery.toLowerCase())) {
        state.setSearchResult(userDetail);
      }
    });

    if (state.getSearchResult.isEmpty) {
      state.clearSearchResult();
    }
  }

  void _stopSearching(QuranSettings state) {
    _clearSearchQuery(state);
    state.setIsSearching = false;
  }

  void _clearSearchQuery(QuranSettings state) {
    _searchQueryController.clear();
    updateSearchQuery("", state);
  }

  // List<SurahsModel> surahs;

  // old

  FutureBuilder<String> surahListBuilder(
      BuildContext context, QuranSettings state) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/quran/surah_list.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        state.setSurahsModelList = parseJosn(snapshot.data.toString());

        return state.getSearchResult.length < 1 &&
                _searchQueryController.text.isEmpty
            ? ListView.separated(
                itemCount: state.getSurahsModelList.length,
                separatorBuilder: (context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Divider(
                      thickness: 2.0,
                    ),
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return surahListTiles(
                      context, state.getSurahsModelList, index, state);
                },
              )
            : ListView.separated(
                itemCount: state.getSearchResult.length,
                separatorBuilder: (context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Divider(
                      thickness: 2.0,
                    ),
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return surahListTiles(
                      context, state.getSearchResult, index, state);
                },
              );
      },
    );
  }

  ListTile surahListTiles(BuildContext context, List<SurahsModel> surahs,
      int index, QuranSettings state) {
    return ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Surah(
                      surahEn: surahs[index].name,
                      // number: (index + 1).toString(),
                      number: int.parse(surahs[index].number).toString(),
                      surahAr: surahs[index].nameAr,
                      ayahCount: surahs[index].ayyahs,
                    )));
      },
      leading: surahAndJuzListNumberIcon(index, state),
      title: surahEnName(surahs, index, state),
      subtitle: ayahCount(surahs, index, state),
      trailing: surahArName(surahs, index, state),
    );
  }

  Text surahEnName(List<SurahsModel> surahs, int index, QuranSettings state) {
    return Text(
      surahs[index].name,
      style: state.translationFont != null
          ? GoogleFonts.getFont(state.translationFont)
          : TextStyle(fontSize: state.translationFontSize ?? 14),
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

  Text ayahCount(List<SurahsModel> surahs, int index, QuranSettings state) {
    return Text(
      surahs[index].type + ' - ' + surahs[index].ayyahs.toString() + " ayahs",
      style: state.translationFont != null
          ? GoogleFonts.getFont(state.translationFont)
          : TextStyle(fontSize: state.translationFontSize ?? 14),
    );
  }
}
