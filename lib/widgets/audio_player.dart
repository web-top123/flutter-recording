import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:just_audio/just_audio.dart' as ap;
import 'package:cross_file/cross_file.dart';
import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:salad_app/main.dart';
import 'package:salad_app/utils/file_storage.dart';
import 'package:salad_app/utils/string.dart';
import 'package:salad_app/widgets/seek_bar.dart';

class AudioPlayer extends StatefulWidget {
  /// Path from where to play recorded audio
  final String source;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onDelete;

  const AudioPlayer({
    Key? key,
    required this.source,
    required this.onDelete,
  }) : super(key: key);

  @override
  AudioPlayerState createState() => AudioPlayerState();
}

class AudioPlayerState extends State<AudioPlayer> {
  bool _loading = false;
  bool _error = false;
  bool _success = false;
  late Uint8List _byteData;

  final _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    // Catching errors during playback (e.g. lost network connection)
    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace st) {
      if (e is PlayerException) {
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
      } else {
        print('An error occurred: $e');
      }
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Some Stuff
      }
    });

    _loadDuration();

    super.initState();
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    print(_audioPlayer.playerState);
    print(_audioPlayer.playing);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControl(),
                  _buildSlider(),
                  // if (_duration != null)
                  // Text(playbackStateText(_position, _duration)),
                ],
              ),
              _actionButtons(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadDuration() async {
    try {
      if (kIsWeb) {
        _byteData = await XFile(widget.source).readAsBytes();
        _duration =
            await _audioPlayer.setAudioSource(BufferAudioSource(_byteData));
      } else {
        _duration = await _audioPlayer.setFilePath(widget.source);
      }
    } on PlayerException catch (e) {
      // iOS/macOS: maps to NSError.code
      // Android: maps to ExoPlayerException.type
      // Web: maps to MediaError.code
      // Linux/Windows: maps to PlayerErrorCode.index
      print("Error code: ${e.code}");
      // iOS/macOS: maps to NSError.localizedDescription
      // Android: maps to ExoPlaybackException.getMessage()
      // Web/Linux: a generic message
      // Windows: MediaPlayerError.message
      print("Error message: ${e.message}");
    } on PlayerInterruptedException catch (e) {
      // This call was interrupted since another audio source was loaded or the
      // player was stopped or disposed before this audio source could complete
      // loading.
      print("Connection aborted: ${e.message}");
    } catch (e) {
      // Fallback for all other errors
      print('An error occured: $e');
    }
  }

  Widget _saveRecordingButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: () async {
          final time = DateTime.now().millisecondsSinceEpoch.toString();
          if (kIsWeb) {
            final file = await XFile(widget.source).readAsBytes();
            await FileSaver.instance.saveFile(
                name: time, bytes: file, mimeType: MimeType.mp3, ext: 'wav');
          } else {
            final file = File.fromUri(Uri.parse(widget.source));
            FileStorage.write(file.toString(), '$time.wav');
          }
        },
        child: const Text('Save locally'));
  }

  Widget _actionButtons() {
    return Column(
      children: [
        if (_error) const Text('An error occurred. Please try again.'),
        if (_success)
          const Text('Your draft article will be emailed to you shortly.'),
        const SizedBox(height: 10),
        _sendTranscriptionButton(),
        const SizedBox(height: 10),
        _restartRecordingButton(),
        const SizedBox(height: 10),
        _saveRecordingButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sendTranscriptionButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: () async {
          setState(() {
            if (_error) _error = false;
            _loading = true;
          });
          try {
            final text = await convertSpeechToText(widget.source, _byteData);
            await supabase.from('transcriptions').insert({'text': text});
            print('Transcription was saved in db');
            setState(() {
              _loading = false;
              _success = true;
            });
          } catch (e) {
            print('Error saving to db');
            setState(() {
              _loading = false;
              _error = true;
            });
          }
        },
        child: Text(_loading ? 'Loading..' : 'Send for transcription'));
  }

  Widget _restartRecordingButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      child: const Text('Restart recording'),
      onPressed: () {
        if (_audioPlayer.playing) {
          stop().then((value) => widget.onDelete());
        } else {
          widget.onDelete();
        }
      },
    );
  }

  Widget _buildControl() {
    final theme = Theme.of(context);

    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        // if (processingState == ProcessingState.loading ||
        //     processingState == ProcessingState.buffering) {
        //   return Container(
        //     margin: const EdgeInsets.all(8.0),
        //     width: 56,
        //     height: 56,
        //     child: const CircularProgressIndicator(),
        //   );
        // }
        if (playing != true) {
          return IconButton(
            icon: Icon(Icons.play_arrow, color: theme.primaryColor),
            iconSize: 56,
            onPressed: _audioPlayer.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause, color: Colors.red),
            iconSize: 56,
            onPressed: _audioPlayer.pause,
          );
        } else {
          return IconButton(
              icon: const Icon(Icons.replay),
              iconSize: 56,
              onPressed: () async {
                await _audioPlayer.seek(Duration.zero);
                _audioPlayer.stop();
              });
        }
      },
    );
  }

  Widget _buildSlider() {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return SeekBar(
          duration: positionData?.duration ?? Duration.zero,
          position: positionData?.position ?? Duration.zero,
          bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
          onChangeEnd: _audioPlayer.seek,
        );
      },
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() => _audioPlayer.pause();

  Future<void> stop() => _audioPlayer.stop();
}

String playbackStateText(Duration? duration, Duration? position) {
  final currentPositionString = durationToString(duration);
  final durationString = durationToString(position);
  return '$currentPositionString/$durationString';
}

Future<String> convertSpeechToText(String filePath, Uint8List? byteData) async {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  final url = Uri.https("api.openai.com", "v1/audio/transcriptions");

  final request = http.MultipartRequest('POST', url);
  request.headers.addAll(({"Authorization": "Bearer $apiKey"}));
  request.fields["model"] = 'whisper-1';
  request.fields["language"] = "en";

  final http.MultipartFile uri;
  if (kIsWeb && byteData != null) {
    uri = http.MultipartFile.fromBytes('file', byteData,
        filename: '${filePath.split("/").last}.wav');
  } else {
    uri = await http.MultipartFile.fromPath('file', Uri.parse(filePath).path);
  }

  // Record plugin path issue: https://github.com/llfbandit/record/issues/170
  request.files.add(uri);

  try {
    final response = await request.send().then((value) async {
      return await http.Response.fromStream(value);
    });
    final responseData = json.decode(response.body);
    final text = responseData['text'];
    print('Transcription was sent: $text');
    return text;
  } catch (e) {
    print(e);
    throw Exception('Failed to transcribe audio.');
  }
}

class BufferAudioSource extends StreamAudioSource {
  final Uint8List _buffer;

  BufferAudioSource(this._buffer) : super(tag: 'BufferAudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) {
    start = start ?? 0;
    end = end ?? _buffer.length;

    return Future.value(
      StreamAudioResponse(
        sourceLength: _buffer.length,
        contentLength: end - start,
        offset: start,
        contentType: 'audio/mpeg',
        stream: Stream.fromIterable([_buffer.sublist(start, end)]),
      ),
    );
  }
}
