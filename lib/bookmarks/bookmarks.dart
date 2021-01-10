import 'dart:convert';

import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surahs_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Bookmarks extends StatefulWidget {
  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  int currentIndex = 0;
  PageController _controller;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        unselectedItemColor: Colors.black45,
        selectedItemColor: Colors.green,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          _controller
              .animateToPage(index,
                  duration: Duration(milliseconds: 300), curve: Curves.easeIn)
              .whenComplete(() {
            currentIndex = index;
            setState(() {});
          });
        },
        items: [
          BottomNavigationBarItem(
              label: 'Surah', icon: ImageIcon(AssetImage('assets/surahs.png'))),
          BottomNavigationBarItem(
              label: 'Juz', icon: ImageIcon(AssetImage('assets/juz.png'))),
          BottomNavigationBarItem(
              label: 'Ayah',
              icon: ImageIcon(AssetImage('assets/ayahtul_kursi.png'))),
          BottomNavigationBarItem(
              label: 'Dua',
              icon: ImageIcon(AssetImage('assets/dua_hands.png'))),
        ],
      ),
      body: Center(
        child: Consumer<QuranSettings>(
          builder: (_, state, child) {
            return PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: [
                Container(child: Text('Bookmarked surahs')),
                Container(child: Text('Bookmarked Juzs')),
                Container(child: Text('Bookmarked Ayahs')),
                Container(child: Text('Bookmarked Duas')),
              ],
            );
          },
        ),
      ),
    );
  }
}
