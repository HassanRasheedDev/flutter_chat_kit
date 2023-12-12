import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../di/service_locator.dart';
import 'extensions.dart';

getUserProfileImagePath(String userId){
  var dirProvider = getIt<ApplicationDirectoryProvider>();
  final appDir = dirProvider.getDirectoryPath();
  final filePath = '${appDir?.path}/$userId.jpg';
  return filePath;
}

getTempUserProfileImagePath(String userId){
  var dirProvider = getIt<ApplicationDirectoryProvider>();
  final appDir = dirProvider.getDirectoryPath();
  final filePath = '${appDir?.path}/temp/$userId.jpg';
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

getUserTempFilePath(String fileName, String userId, String fileExt){
  var dirProvider = getIt<ApplicationDirectoryProvider>();
  final appDir = dirProvider.getDirectoryPath();
  final filePath = '${appDir?.path}/$userId/temp/$fileName.$fileExt';
  return filePath;
}

getCompressedImage(String currentPath, String targetPath, [int quality = 25]) async {
  var file = await FlutterImageCompress.compressAndGetFile(
    currentPath, targetPath,
    quality: quality,
  );
  return file?.path;
}