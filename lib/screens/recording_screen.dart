import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salad_app/main.dart';
import 'package:salad_app/screens/login_screen.dart';
import 'package:salad_app/widgets/audio_player.dart';
import 'package:salad_app/widgets/audio_recorder.dart';

class RecordingScreen extends StatefulWidget {
  final String type;

  const RecordingScreen({super.key, required this.type});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool showPlayer = false;
  String? audioPath;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Writing New ${widget.type}'),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Sign out'),
          )
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: showPlayer
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: AudioPlayer(
                    source: audioPath!,
                    onDelete: () {
                      setState(() => showPlayer = false);
                    },
                  ),
                )
              : AudioRecorder(
                  onRestart: () {
                    setState(() => showPlayer = false);
                  },
                  onDone: (path) {
                    if (kDebugMode) print('Recorded file path: $path');
                    setState(() {
                      audioPath = path;
                      showPlayer = true;
                    });
                  },
                ),
        ),
      ),
    );
  }
}
