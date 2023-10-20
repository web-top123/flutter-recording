import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// To save the file in the device
class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    final isWebiOS = kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final isWebAndroid =
        kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    // To check whether permission is given for this app or not.
    if (isWebAndroid || Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        // If not we will ask for permission first
        await Permission.storage.request();
      }
    }

    Directory directory = Directory("");
    if (isWebAndroid || Platform.isAndroid) {
      // Redirects it to download folder in android
      directory = Directory("/storage/emulated/0/Download");
    } else if (kIsWeb) {
      // directory = await getDownloadsDirectory();
      print('save to web');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final exPath = directory.path;

    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> write(String bytes, String name) async {
    final path = await _localPath;
    File file = File('$path/$name');

    return file.writeAsString(bytes);
  }
}
