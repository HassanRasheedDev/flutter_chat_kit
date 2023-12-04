import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:sendbird_sdk/core/models/user.dart';

import '../di/service_locator.dart';
import '../l10n/string_en.dart';
import '../models/message_model.dart';
import '../utils/file_utils.dart';
import 'package:http/http.dart' as http;

class DownloadRepository{



  DownloadRepository();

  Future<String> getDownloadFilePath(MainMessage message, User? user) async {

    var mediaExt = "jpg";
    if(message.mediaType == Strings.audioMediaType){
      mediaExt = "mp3";
    }
    final appDir = getUserFilePath(message.ts??"0", user?.userId??"users", mediaExt);
    if(await File(appDir).exists()){
      // Don't download if file already exists ...
      return appDir;
    }

    var isConnected = await getIt.get<InternetChecker>().checkInternetConnection();
    if (!isConnected) {
      if (kDebugMode) {
        print('Failed to download image');
      }
      return "";
    }

    final response = await http.get(Uri.parse(message.secureUrl ?? ""));
    if (response.statusCode == 200) {

      final file = await File(appDir).create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);

      if (kDebugMode) {
        print('NH_Image downloaded and saved at: ${file.path}');
      }
      return file.path;
    } else {
      return "";
    }
  }

}