
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_kit/l10n/string_en.dart';
import 'package:hive/hive.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';

import '../controllers/hive_controller.dart';
import '../controllers/login_controller.dart';
import '../db_helper.dart';
import '../main.dart';
import '../models/message_model.dart';
import '../utils/extensions.dart';
import '../utils/file_utils.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> downloadImages(String command) async {

  Map<String, String> mapOfIds = {
    "101": "f8b3f6701e8b71c0cb6798f8ab4228413796857c",
    "102": "346e897fad8f460ded37610b4abac499c6f214ad",
    "103": "864d68d63bd1ea12aa248d80811c41d1e5dddd11",
    "104": "5e8b104d4b8abb1250d271029164b61ffe658629"
  };


  // initializing db ...
  var dbHelper = DBHelper();
  // initializing InternetChecker ...
  var isConnected = await InternetChecker().checkInternetConnection();

  var dirProvider = ApplicationDirectoryProvider();

  // First logging in the user and then getting the e-Auth key ...;
  final hiveController = HiveController();

  Box userBox = await hiveController.getHiveBox(HiveController.boxNameUsers);
  final userProfile = await userBox.get("profile");
  var eAuthenticationKey = "";

  if(isConnected){

    if (userProfile != null){
      final user = await sendbird.connect(userProfile["user_id"], accessToken: mapOfIds[userProfile["user_id"]] ?? "");
      final sdk = SendbirdSdk().getInternal();
      final eKey = sdk.sessionManager.getEKey();
      eAuthenticationKey = eKey ?? "";
    }

    // Get data from database where files are with no local url ...
    var imageFiles = await dbHelper.getAudioFilesWithNoLocalUrl();


    if(imageFiles != null && imageFiles.isNotEmpty == true && eAuthenticationKey.isNotEmpty){

      for (var item in imageFiles) {
        var msg = MainMessage.fromDBResultSet(item);

          final appDir = getOtherUserFilePath(dirProvider, msg, Strings.imageExtension);
          if(!await File(appDir).exists()){
            var url = "${msg.secureUrl}$eAuthenticationKey";
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200){

              String finalPath = await getImageDownloadedFilePath(response, msg, appDir, dirProvider);

              if (kDebugMode) {
                print('NH_Image downloaded and saved at: $finalPath');
              }

              dbHelper.updateLocalFilePath(finalPath, msg.ts ?? "");
            }

          }
      }
    }
  }
}

getOtherUserFilePath(dirProvider, message , String fileExt){
  String fileName = message?.ts ??"1";
  String userId = message?.senderUserId ?? "users";
  final appDir = dirProvider.getDirectoryPath();
  final filePath = '${appDir?.path}/$userId/$fileName.$fileExt';
  return filePath;
}

getImageDownloadedFilePath(http.Response response, message, appDir, dirProvider) async {

  String filePath = "";

  final tempAppDir = getOtherUserTempFilePath(message, Strings.imageExtension, dirProvider);
  final tempFile = await File(tempAppDir).create(recursive: true);
  await tempFile.writeAsBytes(response.bodyBytes);

  // -->  TODO : greater than 1MB
  filePath = await getCompressedImage(tempFile.absolute.path, appDir);
  tempFile.delete();

  return filePath;

}

getOtherUserTempFilePath(message, String fileExt, dirProvider){
  String fileName = message?.ts ??"1";
  String userId = message?.senderUserId ?? "users";
  final appDir = dirProvider.getDirectoryPath();
  final filePath = '${appDir?.path}/$userId/temp/$fileName.$fileExt';
  return filePath;
}

