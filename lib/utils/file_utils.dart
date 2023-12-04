import 'package:flutter_chat_kit/models/message_model.dart';

import '../di/service_locator.dart';
import 'extensions.dart';

getUserProfileImagePath(String userId){
  var dirProvider = getIt<ApplicationDirectoryProvider>();
  final appDir = dirProvider.getDirectoryPath();
  final filePath = '${appDir?.path}/$userId.jpg';
  return filePath;
}

getAppDirectoryPath(){
  var dirProvider = getIt<ApplicationDirectoryProvider>();
  final appDir = dirProvider.getDirectoryPath();
  return appDir;
}

getUserFilePath(String fileName, String userId, String fileExt){
  var dirProvider = getIt<ApplicationDirectoryProvider>();
  final appDir = dirProvider.getDirectoryPath();
  final filePath = '${appDir?.path}/$userId/$fileName.$fileExt';
  return filePath;
}