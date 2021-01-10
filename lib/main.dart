import 'package:al_quran/duas/dua_list.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'juz/juz_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuranSettings(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _getUserSettings() async {
    var state = Provider.of<QuranSettings>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state.setShowTranslation = prefs.getBool('showTranslation') ?? true;
    state.setArFont = prefs.getString('QuranFont') ?? 'uthmani';
    state.setTranslationFont = prefs.getString('translationFont') ?? 'Lato';
    state.setArFontSize = prefs.getDouble('arFontSize') ?? 22;
    state.setTranslationFontSize = prefs.getDouble('translationFontSize') ?? 14;
    state.setPaperTheme = prefs.getString('paperTheme') ?? null;
  }

  @override
  void initState() {
    _getUserSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Al-Qur\'an'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Image(
                      image: AssetImage('assets/quran.png'),
                      height: 300,
                    ),
                  ),
                  _homepage_widgets(
                    name: 'Surahs',
                    asset: 'assets/surahs.png',
                    ontap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SurahList())),
                  ),
                  _homepage_widgets(
                    name: 'Juz',
                    asset: 'assets/juz.png',
                    ontap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => JuzList())),
                  ),
//TODO
//                  _homepage_widgets(
//                      name: 'Last Read', asset: 'assets/last_read.png'),
//                  _homepage_widgets(
//                    name: 'Bookmarks',
//                    asset: 'assets/bookmark.png',
//                    ontap: () => Navigator.push(context,
//                        MaterialPageRoute(builder: (context) => Bookmarks())),
//                  ),
                  _homepage_widgets(
                    name: 'Duas',
                    asset: 'assets/kid_dua.png',
                    ontap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DuaList())),
                  ),
                  SizedBox(
                    height: 140.0,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _homepage_widgets(
      {String name, String asset, Function ontap}) {
    return GestureDetector(
      onTap: () => ontap(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 100.0,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(image: AssetImage(asset)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
