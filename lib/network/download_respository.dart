import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sendbird_sdk/core/models/user.dart';

import '../di/service_locator.dart';
import '../l10n/string_en.dart';
import '../main.dart';
import '../models/message_model.dart';
import '../utils/file_utils.dart';
import 'package:http/http.dart' as http;

class DownloadRepository{

  DownloadRepository();

  Future<String> getDownloadFilePath(MainMessage message, User? user) async {

    var mediaExt = Strings.imageExtension;
    if(message.mediaType == Strings.audioMediaType){
      mediaExt = Strings.audioExtension;
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

      String finalPath = "";
      if(message.mediaType == Strings.audioMediaType){
        finalPath = await getAudioDownloadedFilePath(response,message,user,mediaExt);

      }else{
        finalPath = await getImageDownloadedFilePath(response,message,user,mediaExt,appDir);
      }

      if (kDebugMode) {
        print('NH_Image downloaded and saved at: $finalPath');
      }

      return finalPath;
    } else {
      return "";
    }

  }

  Future<String> getImageDownloadedFilePath(response ,message, user, mediaExt, appDir) async {

    String filePath = "";

    final tempAppDir = getUserTempFilePath(message.ts??"0", user?.userId??"users", mediaExt);
    final tempFile = await File(tempAppDir).create(recursive: true);
    await tempFile.writeAsBytes(response.bodyBytes);

    // -->  greater than 1MB
    if(tempFile.lengthSync() > 10000){
      filePath = await getCompressedImage( tempFile.absolute.path, appDir);
      tempFile.delete();
    }else{
      filePath = await getAudioDownloadedFilePath(response ,message, user, mediaExt);
    }

    return filePath;
  }

  Future<String> getAudioDownloadedFilePath(response ,message, user, mediaExt) async {
    final appDir = getUserFilePath(message.ts??"0", user?.userId??"users", mediaExt);
    final file = await File(appDir).create(recursive: true);
    await file.writeAsBytes(response.bodyBytes);

    return file.path;
  }

}