import 'dart:async';

import 'package:al_quran/surahs/surah_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final PlayerMode mode;
  List<Ayahs> ayahsList = [];
  final Function() notifyParent;

  PlayerWidget(
      {Key key,
      this.mode = PlayerMode.MEDIA_PLAYER,
      @required this.ayahsList,
      this.notifyParent})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    print("112233 number: ${this.ayahsList.length}");
    return _PlayerWidgetState(notifyParent, mode, ayahsList);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  // String url;
  PlayerMode mode;
  List<Ayahs> ayahsList = [];

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  final Function() notifyParent;

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

  _PlayerWidgetState(this.notifyParent, this.mode, this.ayahsList);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('previous_button'),
              onPressed: () {
                widget.notifyParent();
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
            /*IconButton(
              onPressed: _earpieceOrSpeakersToggle,
              iconSize: 64.0,
              icon: _isPlayingThroughEarpiece
                  ? Icon(Icons.volume_up)
                  : Icon(Icons.hearing),
              color: Colors.cyan,
            ),*/
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
          title: 'App Name',
          artist: 'Artist or blank',
          albumTitle: 'Name or blank',
          imageUrl: 'url or blank',
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

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

/*Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
          _playingRouteState == PlayingRouteState.speakers
              ? PlayingRouteState.earpiece
              : PlayingRouteState.speakers);
    return result;
  }*/

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
  }
}
