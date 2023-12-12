import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/controllers/channel_controller.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import '../../styles/text_styles.dart';
import 'message_item.dart';

class UserMessageItem extends MessageItem {
  UserMessageItem({super.key,
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
  Widget get content => Container(
    margin: (isMyMessage ?? false) ? const EdgeInsets.only(right: 8) : const EdgeInsets.only(left: 8),
    constraints: BoxConstraints(maxWidth: MediaQuery.of(mainContext).size.width * 0.7),
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: (isMyMessage ?? false)
          ? lightgreyColor2
          : lightblueColor2,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TimestampedChatMessage(
      text: curr.message,
      sentAt: currTime,
      sentAtStyle: TextStyles.txtProximaNovaNormal12(
        lightgreyColor3,
      ),
      sendingStatusIcon: (isMyMessage ?? false)
          ? Icon( curr.sendingStatusIcon,
          color: greyColor4,
          size: 13.0)
          : null,
      style: TextStyles.txtProximaNovaBold14LineHeight20(greyColor5),
    ),

  );


}
