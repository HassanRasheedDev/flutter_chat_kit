import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/styles/colors.dart';

import '../../../utils/img_constants.dart';

class ImageDialog extends StatelessWidget {
  ImageDialog({super.key, required this.message});
  MainMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child:  Stack(
        children: [
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 50,bottom: 50),
              child: Center(
                child: (message.localFileUrl != null && message.localFileUrl?.isNotEmpty == true) ?
                Image.file(
                  File(message.localFileUrl ?? ""),
                  fit: BoxFit.cover,
                ) : CachedNetworkImage(

                  fit: BoxFit.cover,
                  imageUrl: message.secureUrl ?? "",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: downloadProgress.progress,
                              color: primaryColor,
                            ),
                            Positioned(
                              child: Text(
                                '${((downloadProgress.progress ?? 0.0) * 100)
                                    .toInt()} %',
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  errorWidget: (context, url, error) => ImageConstant.precachedPlaceHolder,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}