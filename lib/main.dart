import 'dart:async';
import 'dart:io';

import 'package:al_quran/duas/dua_list.dart';
import 'package:al_quran/juz/juz_provider.dart';
import 'package:al_quran/recitationAndTranslation/recitation_provider.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpClient;
import 'package:path_provider/path_provider.dart';
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
    return MultiProvider(
      // create: (context) => QuranSettings(),
      providers: [
        ChangeNotifierProvider<QuranSettings>(
          create: (context) => QuranSettings(),
        ),
        ChangeNotifierProvider<RecitationProvider>(
          create: (context) => RecitationProvider(),
        ),
        ChangeNotifierProvider<JuzProvider>(
          create: (context) => JuzProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.white,
        ),
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Colors.white70,
          ),
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
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
    var provider = Provider.of<RecitationProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state.setShowTranslation = prefs.getBool('showTranslation') ?? true;
    state.setArFont = prefs.getString('QuranFont') ?? 'uthmani';
    state.setTranslationFont = prefs.getString('translationFont') ?? 'Lato';
    state.setArFontSize = prefs.getDouble('arFontSize') ?? 22;
    state.setTranslationFontSize = prefs.getDouble('translationFontSize') ?? 14;
    state.setPaperTheme = prefs.getString('paperTheme') ?? null;
    provider.setTranslationIdentifier = prefs.getString('translationIdentifier') ?? "en.ahmedali";
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
        brightness: Brightness.dark,
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
                    child: Hero(
                      tag: "logo",
                      child: Image(
                        image: AssetImage('assets/quran.png'),
                        height: 300,
                      ),
                    ),
                  ),
                  _homepage_widgets(
                    name: 'Surahs',
                    asset: 'assets/surahs.png',
                    ontap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SurahList())),
                  ),
                  _homepage_widgets(
                    name: 'Juz',
                    asset: 'assets/juz.png',
                    ontap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => JuzList())),
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
                    ontap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DuaList())),
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

  GestureDetector _homepage_widgets({String name, String asset, Function ontap}) {
    return GestureDetector(
      onTap: () => ontap(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 100.0,
          decoration: BoxDecoration(
            // color: Colors.green,
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
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

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool fileLoading = false;

  @override
  void initState() {
    super.initState();

    _waitFunction();
    // _fileAlreadyDownloaded("ar.alafasy");
    // _fileAlreadyDownloaded("en.ahmedali");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Hero(
            tag: "logo",
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/quran.png'),
                  height: 300,
                ),
                Text(
                  "Al-Qur-an",
                  style: TextStyle(fontSize: 24),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
                Visibility(
                  visible: fileLoading,
                  child: Text(
                    "Getting files ready. Please wait",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _waitFunction() async {
    await downloadTranslation("ar.alafasy");
    await downloadTranslation("en.ahmedali");
    openHomeScreen();
  }

  Future _fileAlreadyDownloaded(String identifier) async {
    final Directory directory = Platform.isIOS ? await getLibraryDirectory() : await getExternalStorageDirectory();
    final File file = File('${directory.path}/$identifier.json');
    print("file exist: ${file.exists()}, ${file.path}");
    return await file.exists();
  }

  Future<File> downloadTranslation(String identifier) async {
    if (!await _fileAlreadyDownloaded(identifier)) {
      setState(() {
        fileLoading = true;
      });
      var response;
      try {
        response = await httpClient.get(Uri.parse("http://api.alquran.cloud/v1/quran/$identifier"));

        final client = new HttpClient();
        client.connectionTimeout = const Duration(seconds: 10);

      } catch (e) {
        print("Error: $e");
      }
      if (response.statusCode == 200) {
        final Directory directory = Platform.isIOS ? await getLibraryDirectory() : await getExternalStorageDirectory();
        final File file = File('${directory.path}/$identifier.json');
        return await file.writeAsString(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
  }

  openHomeScreen() {
    setState(() {
      fileLoading = false;
    });
    Timer(Duration(seconds: 2),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MyHomePage())));
  }
}
