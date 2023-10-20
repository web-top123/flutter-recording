import 'package:flutter/material.dart';
import 'package:salad_app/main.dart';
import 'package:salad_app/screens/login_screen.dart';
import 'package:salad_app/screens/recording_screen.dart';

class SelectRecordingScreen extends StatefulWidget {
  const SelectRecordingScreen({super.key});

  @override
  State<SelectRecordingScreen> createState() => _SelectRecordingScreenState();
}

class _SelectRecordingScreenState extends State<SelectRecordingScreen> {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text("Let's get creative.", style: TextStyle(fontSize: 32)),
                  SizedBox(height: 20),
                  Text("What would you like help writing today?",
                      style: TextStyle(fontSize: 32)),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const RecordingScreen(type: 'Article'),
                          ),
                        );
                      },
                      child: const Text('Article')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const RecordingScreen(type: 'Journal Entry'),
                          ),
                        );
                      },
                      child: const Text('Journal entry')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const RecordingScreen(type: 'Film Script'),
                          ),
                        );
                      },
                      child: const Text('Film script')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const RecordingScreen(type: 'Short Story'),
                          ),
                        );
                      },
                      child: const Text('Short story')),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
