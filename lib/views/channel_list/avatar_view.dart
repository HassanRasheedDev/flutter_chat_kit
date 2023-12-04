import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/di/service_locator.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart' hide ConnectionState;
import 'package:http/http.dart' as http;

class AvatarView extends StatelessWidget {
  final MainChannel? channel;
  final User? user;
  final String? currentUserId;
  final double width;
  final double height;
  final Function()? onPressed;

  const AvatarView({
    super.key,
    this.channel,
    this.user,
    this.currentUserId,
    this.width = 40,
    this.height = 40,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a channel image from avatars of users, excluding current user
    syncImage();

    return FutureBuilder<Image?>(
      future: getImage(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return getImagePlaceHolder();
        } else if (snapshot.hasError) {
          return getImagePlaceHolder();
        } else if (snapshot.data == null) {
          return getImagePlaceHolder();
        } else {
         return  snapshot.data!;
        }
      },
    );
  }

  getImagePlaceHolder() {
    return const Image(image: AssetImage('assets/iconAvatarLight@3x.png'));
  }

  Future<Image?> getImage(context) async {
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/${channel?.key}.jpg';

    if (await File(filePath).exists()) {
      return Image.file(File(filePath));
    } else {
      if (kDebugMode) {
        print('Image file does not exist.');
      }
      return getMemberProfileUrl();
    }
  }

  Image getMemberProfileUrl() {
    if (channel?.channelImageUrl?.isNotEmpty == true) {
      var imageLink = channel?.channelImageUrl ?? "";
      return Image(image: NetworkImage(imageLink), fit: BoxFit.cover);
    } else {
      return const Image(image: AssetImage('assets/iconAvatarLight@3x.png'));
    }
  }

  Future<void> syncImage() async {
    var isConnected = await getIt<InternetChecker>().checkInternetConnection();
    if (!isConnected) {
      if (kDebugMode) {
        print('Failed to download image');
      }
      return;
    }
    if (channel?.channelImageUrl?.isNotEmpty == true) {
      var imageLink = channel?.channelImageUrl ?? "";

      if (kDebugMode) {
        print("downloading avatar::  $imageLink");
      }

      if (imageLink.isNotEmpty) {
        final response = await http.get(Uri.parse(imageLink));
        if (response.statusCode == 200) {
          final appDir = await getApplicationDocumentsDirectory();
          final file = await File('${appDir.path}/${channel?.key}.jpg').create(recursive: true);

          await file.writeAsBytes(response.bodyBytes);

          if (kDebugMode) {
            print('AV_Image downloaded and saved at: ${file.path}');
          }
        } else {
          throw Exception('Failed to load image');
        }
      }
    }
  }
}
