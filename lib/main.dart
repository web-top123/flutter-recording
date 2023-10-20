import 'package:flutter/material.dart';
import 'package:salad_app/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://cijbetgzdgqkiilfskne.supabase.co';
const supabaseKey = String.fromEnvironment('API_KEY');

void main() async {
  await Supabase.initialize(
      url: supabaseUrl, anonKey: supabaseKey, authFlowType: AuthFlowType.pkce);

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salad App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
