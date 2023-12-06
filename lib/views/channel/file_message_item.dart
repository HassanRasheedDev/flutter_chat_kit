import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:flutter_chat_kit/controllers/channel_controller.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:flutter_chat_kit/views/channel/message_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:sendbird_sdk/constant/enums.dart';

import '../../styles/text_styles.dart';

class FileMessageItem extends MessageItem {
  FileMessageItem({
    super.key,
    required MainMessage curr,
    MainMessage? prev,
    MainMessage? next,
    required ChannelController controller,
    required bool isMyMessage,
    Function(Offset)? onPress,
    Function(Offset)? onLongPress,
  }) : super(
    curr: curr,
    prev: prev,
    next: next,
    model: controller,
    isMyMessage: isMyMessage,
    onPress: onPress,
    onLongPress: onLongPress,
  );

  @override
  Widget get content =>
      Container(
        constraints:
        const BoxConstraints(maxWidth: 268,),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: (isMyMessage ?? false)
              ? lightgreyColor2
              : lightblueColor2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
              ((curr.localFileUrl != null &&
                  curr.localFileUrl?.isNotEmpty == true) &&
                  kIsWeb == false)
                  ? InkWell(
                onTap: () {

                  Navigator.push(
                    mainContext,
                    MaterialPageRoute(builder: (context) =>
                        ImageDialog(localPath: curr.localFileUrl ?? "", Type: 'Local',),
                      fullscreenDialog: true,
                    ),);
                },
                child: SizedBox(
                  height: 184,
                  width: 252,
                  child: Image.file(
                    File((curr).localFileUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  :

              InkWell(
                onTap: () {

                  Navigator.push(
                      mainContext,
                      MaterialPageRoute(builder: (context) =>
                      ImageDialog(secureUrl: curr.secureUrl ?? "", Type: 'Network',),
                  fullscreenDialog: true,
                  ),);
                },
                child: CachedNetworkImage(
                  height: 184,
                  width: 252,
                  fit: BoxFit.cover,
                  imageUrl: (curr).secureUrl ?? "",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: downloadProgress.progress,
                              color: progressColor,
                            ),
                            Positioned(
                              child: Text(
                                '${((downloadProgress.progress ?? 0.0) * 100)
                                    .toInt()} %',
                                style: const TextStyle(
                                  color: progressColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  currTime,
                  style: TextStyles.txtProximaNovaNormal12(
                    lightgreyColor3,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                curr.isMyMessage
                    ? Icon(Icons.done_all,
                    color:
                    curr.sendingStatus == MessageSendingStatus.succeeded
                        ? skyblueColor
                        : greyColor4,
                    size: 16.0)
                    : const SizedBox.shrink(),
              ],
            )
          ],
        ),
      );

}




class ImageDialog extends StatelessWidget {
   ImageDialog({super.key, this.localPath,required this.Type,this.secureUrl});
  String? localPath;
  String Type;
  String? secureUrl;
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
                child: (Type == "Local") ? Image.file(
                  File(localPath ?? ""),
                  fit: BoxFit.cover,
                ) : CachedNetworkImage(

                  fit: BoxFit.cover,
                  imageUrl: secureUrl ?? "",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: downloadProgress.progress,
                              color: progressColor,
                            ),
                            Positioned(
                              child: Text(
                                '${((downloadProgress.progress ?? 0.0) * 100)
                                    .toInt()} %',
                                style: const TextStyle(
                                  color: progressColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
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
