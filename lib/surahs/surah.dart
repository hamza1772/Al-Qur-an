import 'dart:async';
import 'dart:convert';

import 'package:al_quran/recitationAndTranslation/recitation_settings.dart';
import 'package:al_quran/settings/settings_provider.dart';
import 'package:al_quran/surahs/surah_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_widgets.dart';

enum PlayerState { stopped, playing, paused }

enum PlayingRouteState { speakers, earpiece }

class Surah extends StatefulWidget {
  final String surahEn;
  final String surahAr;
  final String number;
  final int ayahCount;

  Surah({this.surahEn, this.number, this.surahAr, this.ayahCount});

  @override
  _SurahState createState() => _SurahState();
}

class _SurahState extends State<Surah> {
  // mine

  PlayerMode mode;
  List<Ayahs> ayahsList = null;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  StreamSubscription<PlayerControlCommand> _playerControlCommandSubscription;

  get _isPlaying => _playerState == PlayerState.playing;

  get _isPaused => _playerState == PlayerState.paused;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';

  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  Future myFuture;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();

    myFuture = getSurah(context);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   if (oldWidget.future != myFuture) {
  //     if (_activeCallbackIdentity != null) {
  //       _unsubscribe();
  //       // Snapshot state is reset here
  //       _snapshot = _snapshot.inState(ConnectionState.none);
  //     }
  //     _subscribe();
  //   }
  // }

  /*@override
  void didUpdateWidget(FutureBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) {
      if (_activeCallbackIdentity != null) {
        _unsubscribe();
        // Snapshot state is reset here
        _snapshot = _snapshot.inState(ConnectionState.none);
      }
      _subscribe();
    }
  }*/

  Widget PlayerWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('previous_button'),
              onPressed: () {
                _previous();
              },
              icon: Icon(Icons.skip_previous),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('play_button'),
              onPressed: _isPlaying ? null : () => _play(),
              // iconSize: 64.0,
              icon: Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('pause_button'),
              onPressed: _isPlaying ? () => _pause() : null,
              // iconSize: 64.0,
              icon: Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? () => _stop() : null,
              // iconSize: 64.0,
              icon: Icon(Icons.stop),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('next_button'),
              // onPressed: _isPlaying || _isPaused ? () => _stop() : null,
              onPressed: () => _next(),
              icon: Icon(Icons.skip_next),
              color: Colors.cyan,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            // mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                _position != null
                    ? '${_positionText ?? ''}'
                    : _duration != null
                        ? _durationText
                        : '',
                // style: TextStyle(backgroundColor: Colors.red),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight:
                        5, //<------Change this number here to change the height----
                    // thumbShape:
                    //     RoundSliderThumbShape(enabledThumbRadius: 0.0),
                  ),
                  child: Slider(
                    onChanged: (v) {
                      final Position = v * _duration.inMilliseconds;
                      _audioPlayer
                          .seek(Duration(milliseconds: Position.round()));
                    },
                    value: (_position != null &&
                            _duration != null &&
                            _position.inMilliseconds > 0 &&
                            _position.inMilliseconds < _duration.inMilliseconds)
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                  ),
                ),
              ),
              Text(
                _position != null
                    ? '${_durationText ?? ''}'
                    : _duration != null
                        ? _durationText
                        : '',
                // style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
        ),
        // Text('State: $_audioPlayerState')
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // TODO implemented for iOS, waiting for android impl
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
          title: 'Al-Qur-an',
          artist: 'Al-Qur-an',
          albumTitle: 'Al-Qur-an',
          // imageUrl: '',
          // forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          // backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          elapsedTime: Duration(seconds: 0),
          hasNextTrack: true,
          hasPreviousTrack: false,
        );
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _playerControlCommandSubscription =
        _audioPlayer.onPlayerCommand.listen((command) {
      print('command');
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  int currentIndex = 0;

  Future<String> _next() async {
//    5 > 5
    if (ayahsList.length > currentIndex + 1) {
      itemScrollController.jumpTo(
        index: currentIndex + 1,
      );
      /*itemScrollController.scrollTo(
          index: currentIndex + 1, duration: Duration(seconds: 1));*/
      final result = await _audioPlayer.stop();
      if (result == 1) {
        setState(() async {
          _playerState = PlayerState.stopped;
          _position = Duration();

          currentIndex++;

          final playPosition = (_position != null &&
                  _duration != null &&
                  _position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _duration.inMilliseconds)
              ? _position
              : null;
          final result = await _audioPlayer.play(ayahsList[currentIndex].audio,
              position: playPosition);

          if (result == 1) setState(() => _playerState = PlayerState.playing);

          _audioPlayer.setPlaybackRate(playbackRate: 1.0);
        });
      }
    }
  }

  Future<String> _previous() async {
    if (currentIndex != 0) {
      itemScrollController.jumpTo(index: currentIndex - 1);
      /*itemScrollController.scrollTo(
          index: currentIndex - 1, duration: Duration(seconds: 1));*/
      final result = await _audioPlayer.stop();
      if (result == 1) {
        setState(() async {
          _playerState = PlayerState.stopped;
          _position = Duration();

          currentIndex--;

          final playPosition = (_position != null &&
                  _duration != null &&
                  _position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _duration.inMilliseconds)
              ? _position
              : null;
          final result = await _audioPlayer.play(ayahsList[currentIndex].audio,
              position: playPosition);

          if (result == 1) setState(() => _playerState = PlayerState.playing);

          _audioPlayer.setPlaybackRate(playbackRate: 1.0);
        });
      }
    }
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(ayahsList[currentIndex].audio,
        position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
    _next();
  }

  // old
  final ItemScrollController itemScrollController = ItemScrollController();

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  List<SurahModel> parseJson(String response) {
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
    return Scaffold(
      appBar: AppBar(
        flexibleSpace:
            FlexibleSpaceBar(centerTitle: true, title: _surahAppbar(context)),
        actions: [
          // recitationTranslationNav(context),
          IconButton(
            icon: Icon(Icons.menu_book_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecitationSetting(),
              ),
            ).then((value) async {
              /*setState(() {
                myFuture = null;
              });*/

              if (identifier != null) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var variable =
                    prefs.getString('translationIdentifier') ?? "en.ahmedali";
                if (identifier != variable) {
                  setState(() {
                    translationList = null;
                    myFuture = getSurah(context);
                  });
                }
              }
              // buildSurah(context);
            }),
          ),
          settingsNav(context),
        ],
      ),
      body: Center(
        child: Consumer<QuranSettings>(
          builder: (_, state, child) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    child: buildSurah(context),
                    decoration: state.paperTheme != null
                        ? BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/papers/${state.paperTheme}'),
                                fit: BoxFit.cover),
                          )
                        : null,
                  ),
                ),
                Visibility(
                  visible: translationList != null,
                  child: Container(
                    child: PlayerWidget(),
                    decoration: state.paperTheme != null
                        ? BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/papers/${state.paperTheme}'),
                                fit: BoxFit.cover),
                          )
                        : null,
                  ),
                ),
              ],
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
                  surah: widget.surahEn,
                  ayahCount: widget.ayahCount,
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
      widget.surahEn.toString(),
      style: state.translationFont != null
          ? GoogleFonts.getFont(state.translationFont)
          : TextStyle(fontSize: state.translationFontSize ?? 16),
    );
  }

  Text _appBarSurahArName() {
    return Text(
      widget.surahAr,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  List<Ayahs> parseUrlJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response);
    Map<String, dynamic> surahs =
        new SurahUrlModel.fromJson(parsed, widget.number)
            .data
            .cast<String, dynamic>();

    Surahs value = new Surahs.fromJson(surahs);

    return value.ayahs;
  }

  Future<String> getSurah(var context) async {
    // var response = await http.get("http://api.alquran.cloud/v1/quran/en.asad");
    // var response = await http.get("http://api.alquran.cloud/v1/quran/ur.khan");
    var response =
        await http.get("http://api.alquran.cloud/v1/quran/ar.alafasy");
    if (response.statusCode == 200) {
      print("112233 here00");
      ayahsList = parseUrlJosn(response.body);

      print("112233 here99");
      translationList = await getTranslation();
      setState(() {});
      print("112233 here88");

      return await DefaultAssetBundle.of(context)
          .loadString('assets/quran/en.pretty.json');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  List<Ayahs> translationList;
  String identifier;

  Future<List<Ayahs>> getTranslation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    identifier = prefs.getString('translationIdentifier') ?? "en.ahmedali";
    var response =
        await http.get("http://api.alquran.cloud/v1/quran/$identifier");
    if (response.statusCode == 200) {
      return parseUrlJosn(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  FutureBuilder<String> buildSurah(BuildContext context) {
    return FutureBuilder(
      future: myFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState != ConnectionState.done)
          // return CircularProgressIndicator();
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Loading ..."),
              )
            ],
          ));

        List<SurahModel> surahs = parseJson(snapshot.data.toString())
            .where(
                (element) => element.surah_number == int.parse(widget.number))
            .toList();

        surahs.forEach((element) {
          ayahsList.forEach((ayahs) {
            if (element.verse_number == ayahs.numberInSurah) {
              element.audio = ayahs.audio;
            }
          });

          translationList.forEach((ayahs) {
            if (element.verse_number == ayahs.numberInSurah) {
              element.translation = ayahs.text;
            }
          });
        });

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
            ? InkWell(
                onTap: () {
                  currentIndex = index - 1;
                  _next();
                },
                child: Column(
                  children: [
                    basmalaTile(context),
                    currentIndex == index
                        ? Container(
                            // margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                                // border: Border.all(color: Colors.blueAccent)
                                color: Colors.yellow.withOpacity(0.6)),
                            child: ayahTlle(index, surahs),
                          )
                        : ayahTlle(index, surahs)
                  ],
                ),
              )
            : InkWell(
                onTap: () {
                  currentIndex = index - 1;
                  _next();
                },
                child: currentIndex == index
                    ? Container(
                        // margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            // border: Border.all(color: Colors.blueAccent)
                            color: Colors.yellow.withOpacity(0.6)),
                        child: ayahTlle(index, surahs),
                      )
                    : ayahTlle(index, surahs),
              );
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
