import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';


const groupChannelDefaultName = 'Group Channel';

class ChannelTitleTextView extends StatelessWidget {
  final MainChannel channel;
  final String? currentUserId;

  const ChannelTitleTextView(this.channel, this.currentUserId, {super.key});

  @override
  Widget build(BuildContext context) {
    String titleText;
    titleText = channel.recipientName ?? "Channel";
    //if channel members == 2 show last seen / online
    //otherwise just text
    return Text(
      titleText,
      maxLines: 1,
      style: Theme.of(context).textTheme.titleSmall,
      overflow: TextOverflow.ellipsis,
    );
  }
}
