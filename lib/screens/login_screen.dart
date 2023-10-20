import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:salad_app/main.dart';
import 'package:salad_app/screens/new_recording_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SelectRecordingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  /// Function to generate a random 16 character string.
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // web
            if (kIsWeb) {
              await supabase.auth.signInWithOAuth(
                Provider.google,
              );
              return;
            }

            const appAuth = FlutterAppAuth();

            // Just a random string
            final rawNonce = _generateRandomString();
            final hashedNonce =
                sha256.convert(utf8.encode(rawNonce)).toString();

            /// Client ID that you registered with Google Cloud.
            /// You will have two different values for iOS and Android.
            final clientId = Platform.isIOS
                ? '96979754402-jcmutcuho7livlvt8jgdm3i5si30n5t6.apps.googleusercontent.com'
                // TODO
                : 'ANDROID_CLIENT_ID';

            /// Set as reversed DNS form of Google Client ID + `:/` for Google login
            final redirectUrl = '${clientId.split('.').reversed.join('.')}:/';

            /// Fixed value for google login
            const discoveryUrl =
                'https://accounts.google.com/.well-known/openid-configuration';

            // authorize the user by opening the concent page
            final result = await appAuth.authorize(
              AuthorizationRequest(
                clientId,
                redirectUrl,
                discoveryUrl: discoveryUrl,
                nonce: hashedNonce,
                scopes: [
                  'openid',
                  'email',
                  'profile',
                ],
              ),
            );

            if (result == null) {
              throw 'No result';
            }

            // Request the access and id token to google
            final tokenResult = await appAuth.token(
              TokenRequest(
                clientId,
                redirectUrl,
                authorizationCode: result.authorizationCode,
                discoveryUrl: discoveryUrl,
                codeVerifier: result.codeVerifier,
                nonce: result.nonce,
                scopes: [
                  'openid',
                  'email',
                ],
              ),
            );

            final idToken = tokenResult?.idToken;

            if (idToken == null) {
              throw 'No idToken';
            }

            await supabase.auth.signInWithIdToken(
              provider: Provider.google,
              idToken: idToken,
              nonce: rawNonce,
            );
          },
          child: const Text('Google login'),
        ),
      ),
    );
  }
}
