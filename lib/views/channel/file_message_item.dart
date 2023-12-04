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
  FileMessageItem({super.key,
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
  Widget get content => Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ((curr.localFileUrl != null && curr.localFileUrl?.isNotEmpty == true) && kIsWeb == false)
                ? SizedBox(
                    height: 160,
                    width: 240,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.file(File((curr).localFileUrl!)),
                    ),
                  )
                : CachedNetworkImage(
                    height: 160,
                    width: 240,
                    fit: BoxFit.cover,
                    imageUrl: (curr).secureUrl ?? "",
                    placeholder: (context, url) => Container(
                      color: primaryColor,
                      width: 30,
                      height: 30,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
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
                  color: curr.sendingStatus == MessageSendingStatus.succeeded
                      ? skyblueColor
                      : greyColor4,
                  size: 16.0)
                  : const SizedBox.shrink(),

            ],
          )
        ],
      );

}
