import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/controllers/channel_controller.dart';
import 'package:flutter_chat_kit/main.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:flutter_chat_kit/views/channel/sender_avatar_view.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_sdk/constant/command_type.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import '../../styles/text_styles.dart';
import '../channel_list/avatar_view.dart';

enum MessagePosition {
  continuous,
  normal,
}

enum MessageState {
  read,
  delivered,
  none,
}

class MessageItem extends StatelessWidget {
  final MainMessage curr;
  final MainMessage? prev;
  final MainMessage? next;
  final bool? isMyMessage;
  final ChannelController model;

  final Function(Offset)? onLongPress;
  final Function(Offset)? onPress;


  Widget get content => throw UnimplementedError();

  String get currTime => DateFormat('kk:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(curr.timeStampInt));

  // PlayerController get playerController => PlayerController();
  //
  // StreamSubscription<PlayerState> get playerStateSubscription => playerController.onPlayerStateChanged.listen((_) {});


  late BuildContext mainContext;

  MessageItem({super.key,
    required this.curr,
    this.prev,
    this.next,
    this.isMyMessage,
    required this.model,
    this.onPress,
    this.onLongPress,
  });


  @override
  Widget build(BuildContext context) {
    mainContext = context;

    final isCenter = isMyMessage == null;
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: _isContinuous(prev, curr) ? 2 : 16,
      ),
      child: Align(
        alignment: isCenter
            ? Alignment.center
            : isMyMessage!
                ? Alignment.topRight
                : Alignment.topLeft,
        child: isCenter
            ? _buildCenterWidget()
            : isMyMessage!
                ? _bulidRightWidget(context)
                : _buildLeftWidget(context),
      ),
    );
  }

  Widget _buildCenterWidget() {
    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        content,
      ],
    );
  }

  Widget _bulidRightWidget(BuildContext ctx) {

    final wrap = Container(
      constraints: const BoxConstraints(maxWidth: 240),
      child: GestureDetector(
          onLongPressStart: (details) {
            if (onLongPress != null) onLongPress!(details.globalPosition);
          },
          onTapDown: (details) {
            if (onPress != null) onPress!(details.globalPosition);
          },
          child: content),
    );

    // List<Widget> children = _timestampDefaultWidget(curr) + [wrap];
    // List<Widget> children = [_additionalWidgetsForRight(curr), wrap];

    List<Widget> children =
        [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [wrap])
        ] ;

    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children + _avatarDefaultWidget(curr, ctx, isLeftWidget: false),
        ),
      ],
    );
  }

  Widget _buildLeftWidget(BuildContext ctx) {
    final wrap = Container(
      constraints: const BoxConstraints(maxWidth: 240),
      child: GestureDetector(
          onLongPressStart: (details) {
            if (onLongPress != null) onLongPress!(details.globalPosition);
          },
          onTapDown: (details) {
            if (onPress != null) onPress!(details.globalPosition);
          },
          child: content),
    );

    List<Widget> children = _avatarDefaultWidget(curr, ctx, isLeftWidget:true) +
        [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _nameDefaultWidget(curr) + [wrap])
        ] +
        [const SizedBox.shrink()];
        //_timestampDefaultWidget(curr);

    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        )
      ],
    );
  }

  bool _isContinuous(MainMessage? p, MainMessage? c) {
    if (p == null || c == null) {
      return false;
    }

    if (p.senderUserId != c.senderUserId) {
      return false;
    }

    final pt = DateTime.fromMillisecondsSinceEpoch(p.timeStampInt);
    final ct = DateTime.fromMillisecondsSinceEpoch(c.timeStampInt);

    final diff = pt.difference(ct);
    if (diff.inMinutes.abs() < 1 && pt.minute == ct.minute) {
      return true;
    }
    return false;
  }

  bool _isSameDate(MainMessage? p, MainMessage? c) {
    if (p == null || c == null) {
      return false;
    }

    final pt = DateTime.fromMillisecondsSinceEpoch(p.timeStampInt);
    final ct = DateTime.fromMillisecondsSinceEpoch(c.timeStampInt);

    return pt.year == ct.year && pt.month == ct.month && pt.day == ct.day;
  }

  Widget _dateWidget(MainMessage message) {
    final date = DateTime.fromMillisecondsSinceEpoch(message.timeStampInt);
    final format = DateFormat('E, MMM d').format(date);

    return Container(
      width: 90,
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                format,
                style: TextStyles.txtRobotoNovaNormal12(
                  lightgreyColor3,
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  Widget _additionalWidgetsForRight(MainMessage message) {
    //status pending -> loader
    if (message.sendingStatus == MessageSendingStatus.pending
        || message.sendingStatus == MessageSendingStatus.failed
        || message.msgId?.isEmpty == true) {
      return Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 3, bottom: 3),
        child: const Image(image: AssetImage('assets/iconError@3x.png')),
      );
    }

    return const SizedBox.shrink();

    // Outer time widget ...
    // return _stateAndTimeWidget(message);

  }

  Widget _stateAndTimeWidget(MainMessage message) {
    final state = model.getMessageState(message);
    final image = state == MessageState.read
        ? const Image(image: AssetImage('assets/iconDoneAll@3x.png'))
        : state == MessageState.delivered
            ? const Image(
                image: AssetImage('assets/iconDoneAll@3x.png'),
                color: Colors.grey,
              )
            : const Image(image: AssetImage('assets/iconDone@3x.png'));

    return Container(
        margin: const EdgeInsets.only(right: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[SizedBox(width: 16, height: 16, child: image)] +
              _timestampDefaultWidget(message),
        ));
  }

  List<Widget> _timestampDefaultWidget(MainMessage message) {
    final myMessage = isMyMessage;
    if (myMessage == null) return [];

    return !_isContinuous(curr, next)
        ? [
            if (!myMessage) const SizedBox(width: 3),
            Text(
              currTime,
              style: TextStyles.sendbirdCaption4OnLight3,
            ),
            if (myMessage) const SizedBox(width: 3)
          ]
        : [];
  }

  List<Widget> _nameDefaultWidget(MainMessage message) {
    return !_isContinuous(prev, curr)
        ? [
            Text(
              " ${message.sender?.nickname ?? ''}",
              style: TextStyles.sendbirdCaption1OnLight2,
            ),
            const SizedBox(height: 4),
          ]
        : [];
  }

  List<Widget> _avatarDefaultWidget(MainMessage message, BuildContext ctx, {required bool isLeftWidget}) {
    // return [const SizedBox(width: 2, height: 2)];
    var padding = message.type == CommandString.fileMessage ? 24.0 : 0.0;
    var currentUser = getSendBirdLocalUser();
    return !_isContinuous(curr, next)
        ? [
            Padding(
              padding: EdgeInsets.only(bottom: padding, left: isLeftWidget ? 0 : 8, right: isLeftWidget? 8 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(64),
                child: SenderAvatarView(
                  channelImageUrl: isLeftWidget  ? message.senderProfileUrl : currentUser?.profileUrl,
                  userId: message.senderUserId,
                  width: 26,
                  height: 26,
                  onPressed: () => (){},
                ),
              ),
            ),
            const SizedBox(width: 8,)
          ]
        : [const SizedBox(width: 38, height: 26)];
  }

}
