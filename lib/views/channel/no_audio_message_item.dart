import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/controllers/channel_controller.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import '../../styles/text_styles.dart';
import 'message_item.dart';

class NoAudioMessageItem extends MessageItem {
  NoAudioMessageItem({super.key,
    required MainMessage curr,
    MainMessage? prev,
    MainMessage? next,
    required ChannelController model,
    bool? isMyMessage,
    Function(Offset)? onPress,
    Function(Offset)? onLongPress
  }) : super(

    curr: curr,
    prev: prev,
    next: next,
    model: model,
    isMyMessage: isMyMessage,
    onPress: onPress,
    onLongPress: onLongPress,
  );

  @override
  Widget get content =>  Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(mainContext).size.width * 0.95),
      padding: const EdgeInsets.only(left: 16.0, right: 10, top: 8, bottom: 3),
      decoration: BoxDecoration(
        color: lightgreyColor7,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(
              height: 6
          ),

          const SizedBox(
            height: 36,
            width: 36,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(skyblueColor3),
              strokeWidth: 2.0,
            ),
          ),

          const SizedBox(
            height: 6
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
                  color: curr.sendingStatus ==
                      MessageSendingStatus.succeeded
                      ? skyblueColor
                      : greyColor4,
                  size: 16.0)
                  : const SizedBox.shrink(),
            ],
          )
        ],
      ));

}
