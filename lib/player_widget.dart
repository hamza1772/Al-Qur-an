import 'dart:async';

import 'package:al_quran/juz/juz_provider.dart';
import 'package:al_quran/surahs/surah.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

enum PlayingRoute { SPEAKERS, EARPIECE }

class PlayerWidget extends StatefulWidget {
  final List<String> audioList;
  final PlayerMode mode;
  final ItemScrollController itemScrollController;

  // final int currentIndex;
  final JuzProvider state;

  const PlayerWidget({
    Key key,
    @required this.audioList,
    @required this.state,
    @required this.itemScrollController,
    this.mode = PlayerMode.MEDIA_PLAYER,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  // String url;
  PlayerMode mode;
  bool buffering = false;
  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.STOPPED;
  PlayingRoute _playingRouteState = PlayingRoute.SPEAKERS;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  bool get _isPlaying => _playerState == PlayerState.PLAYING;

  bool get _isPaused => _playerState == PlayerState.PAUSED;

  String get _durationText => _duration.toString().split('.').first ?? '';

  String get _positionText => _position.toString().split('.').first ?? '';

  bool get _isPlayingThroughEarpiece => _playingRouteState == PlayingRoute.EARPIECE;

  _PlayerWidgetState(this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  int currentIn = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  changePlayerPosition() async {
    currentIn = widget.state.getCurrentIndex;

    if(_isPlaying || _isPaused){
      await _stop();
    }
    await _play();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.getCurrentIndex != currentIn) {
      print("val: ${widget.state.getCurrentIndex}, sec: $currentIn");
      changePlayerPosition();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('previous_button'),
              onPressed: _previous,
              icon: const Icon(Icons.skip_previous_rounded),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              icon: Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              icon: Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              icon: Icon(Icons.stop),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('next_button'),
              onPressed: _next,
              icon: Icon(Icons.skip_next),
              color: Colors.cyan,
            ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              // mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  _position != null
                      ? '${_positionText ?? ''}'
                      : _duration != null
                          ? _durationText
                          : '',
                ),
                Expanded(
                  child: Slider(
                    onChanged: (v) {
                      final duration = _duration;
                      if (duration == null) {
                        return;
                      }
                      final Position = v * duration.inMilliseconds;
                      _audioPlayer.seek(Duration(milliseconds: Position.round()));
                    },
                    value: (_position != null &&
                            _duration != null &&
                            _position.inMilliseconds > 0 &&
                            _position.inMilliseconds < _duration.inMilliseconds)
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                  ),
                ),
                Text(
                  _position != null
                      ? '${_durationText ?? ''}'
                      : _duration != null
                          ? _durationText
                          : '',
                  // style: const TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          ),
        ),
        // Text('State: $_audioPlayerState'),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    /*widget.state.dialCodeStream.listen((event) {
      if (currentIn != event) {
        currentIn = event;
        _play();
      }
    });*/

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      /*if (Theme.of(context).platform == TargetPlatform.iOS) {
        // optional: listen for notification updates in the background
        _audioPlayer.notificationService.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.notificationService.setNotification(
          title: 'App Name',
          artist: 'Artist or blank',
          albumTitle: 'Name or blank',
          imageUrl: 'Image URL or blank',
          forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          enableNextTrackButton: true,
          enablePreviousTrackButton: true,
        );
      }*/
    });

    _positionSubscription = _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
          _position = p;
        }));

    _playerCompleteSubscription = _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.STOPPED;
        _duration = const Duration();
        _position = const Duration();
      });
    });

    /*_audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
      if (mounted) {
        setState(() {
          _audioPlayerState = state;
        });
      }
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _audioPlayerState = state);
      }
    });*/

    _playingRouteState = PlayingRoute.SPEAKERS;
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(widget.audioList[widget.state.getCurrentIndex].replaceAll("https", "http"),
        position: playPosition);
    if (result == 1) {
      setState(() => _playerState = PlayerState.PLAYING);
    }

    return result;
  }

  Future<int> _next() async {
    if (widget.audioList.length > widget.state.getCurrentIndex + 1) {
      widget.itemScrollController.jumpTo(
        index: widget.state.getCurrentIndex + 1,
      );
      final result = await _audioPlayer.stop();

      if (result == 1) {
        setState(() {
          _playerState = PlayerState.STOPPED;
          _position = Duration();

          buffering = true;
          widget.state.setCurrentIndex = widget.state.getCurrentIndex + 1;
          print("112233, currentIndex: ${widget.state.getCurrentIndex}");
        });

        final playPosition = (_position != null &&
                _duration != null &&
                _position.inMilliseconds > 0 &&
                _position.inMilliseconds < _duration.inMilliseconds)
            ? _position
            : null;

        final result = await _audioPlayer.play(widget.audioList[widget.state.getCurrentIndex].replaceAll("https", "http"),
            position: playPosition);
        if (result == 1) {
          setState(() => _playerState = PlayerState.PLAYING);
        }

        return result;
      }
    }
    // return throw ("Unknown error");
  }

  Future<int> _previous() async {
    if (widget.state.getCurrentIndex != 0) {
      widget.itemScrollController.jumpTo(index: widget.state.getCurrentIndex - 1);
      final result = await _audioPlayer.stop();

      if (result == 1) {
        setState(() {
          _playerState = PlayerState.STOPPED;
          _position = Duration();

          buffering = true;
          widget.state.setCurrentIndex = widget.state.getCurrentIndex - 1;
        });

        final playPosition = (_position != null &&
                _duration != null &&
                _position.inMilliseconds > 0 &&
                _position.inMilliseconds < _duration.inMilliseconds)
            ? _position
            : null;

        final result = await _audioPlayer.play(widget.audioList[widget.state.getCurrentIndex].replaceAll("https", "http"),
            position: playPosition);
        if (result == 1) {
          setState(() => _playerState = PlayerState.PLAYING);
        }

        return result;
      }
    }
    return throw ("Unknown error");
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() => _playerState = PlayerState.PAUSED);
    }
    return result;
  }

  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1) {
      // setState(() => _playingRouteState = _playingRouteState.toggle());
    }
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.STOPPED;
        _position = const Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.STOPPED);
    _next();
  }
}
