import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/di/service_locator.dart';
import 'package:flutter_chat_kit/main.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:flutter_chat_kit/utils/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart' hide ConnectionState;
import 'package:http/http.dart' as http;

import '../../utils/img_constants.dart';
import 'package:image/image.dart' as IMG;

class SenderAvatarView extends StatelessWidget {
  final String? channelImageUrl;
  final String? userId;
  final double width;
  final double height;
  final Function()? onPressed;

  String? currentFilePath;

  SenderAvatarView({
    super.key,
    this.channelImageUrl,
    this.userId,
    this.width = 40,
    this.height = 40,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a channel image from avatars of users, excluding current user

    syncImage();

    return isImageExistsInAppDirectory()
        ? getImageFromDirectory()
        : FutureBuilder<Image?>(
            future: getImage(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return getImagePlaceHolder();
              } else if (snapshot.hasError) {
                return getImagePlaceHolder();
              } else if (snapshot.data == null) {
                return getImagePlaceHolder();
              } else {
                return snapshot.data!;
              }
            },
          );
  }

  getImagePlaceHolder() {
    return Image(
        height: height,
        width: width,
        image: const AssetImage('assets/images/user_image.png'));
  }

  Future<Image?> getImage(context) async {

    if (isImageExistsInAppDirectory()) {
      final filePath = currentFilePath ?? "";
      return Image.file(
        File(filePath),
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    } else {
      if (kDebugMode) {
        print('Image file does not exist.');
      }
      return getMemberProfileUrl();
    }
  }

  Image getMemberProfileUrl() {
    if (channelImageUrl?.isNotEmpty == true && isInternetConnected.value == true) {
      return Image(
          height: height,
          width: width,
          image: NetworkImage(channelImageUrl ?? ""),
          fit: BoxFit.cover);
    } else {
      return Image(
          height: height,
          fit: BoxFit.cover,
          width: width,
          image: const AssetImage('assets/images/user_image.png'));
    }
  }

  Future<void> syncImage() async {
    if (isImageExistsInAppDirectory() == true) {
      // Image is already downloaded ...
      return;
    }

    var isConnected = await getIt<InternetChecker>().checkInternetConnection();
    if (!isConnected) {
      if (kDebugMode) {
        print('Failed to download image');
      }
      return;
    }
    var imageLink = channelImageUrl ?? "";
    if (imageLink.isNotEmpty == true) {
      if (kDebugMode) {
        print("downloading sender avatar::  $imageLink");
      }

      if (imageLink.isNotEmpty && !httpImageDownloadRequestsInQueue.contains(channelImageUrl) ) {
        httpImageDownloadRequestsInQueue.add(imageLink);
        final response = await http.get(Uri.parse(imageLink));
        if (response.statusCode == 200) {

          IMG.Image? img = IMG.decodeImage(response.bodyBytes);
          IMG.Image resized = IMG.copyResize(img!, width: 100, height: 100);
          Uint8List? resizedImg = Uint8List.fromList(IMG.encodeJpg(resized));

          final appDir = getUserProfileImagePath(userId ?? "");
          final file = await File(appDir).create(recursive: true);
          file.writeAsBytes(resizedImg);

          // Add new Image
          addNewImageInLocalList(file);

          // Remove image from queue
          httpImageDownloadRequestsInQueue.remove(imageLink);


          if (kDebugMode) {
            print('SA_Image downloaded and saved at: ${file.path}');
          }
        } else {
          throw Exception('Failed to load image');
        }
      }
    }
  }

  bool isImageExistsInAppDirectory() {
    var dirProvider = getIt<ApplicationDirectoryProvider>();
    final filePath = getUserProfileImagePath(userId ??"");
    currentFilePath = filePath;
    return dirProvider.localFiles.containsValue(filePath);
  }

  Widget getImageFromDirectory() {
    return Image.file(
      File(currentFilePath ?? ""),
      height: height,
      width: width,
      fit: BoxFit.cover,
    );
  }

  void addNewImageInLocalList(File file) {
    var dirProvider = getIt<ApplicationDirectoryProvider>();
    dirProvider.localFiles.putIfAbsent("$userId.jpg", () => file.path);
  }

}
