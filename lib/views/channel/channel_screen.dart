import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/controllers/channel_controller.dart';
import 'package:flutter_chat_kit/main.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:flutter_chat_kit/views/channel/audio_file_item.dart';
import 'package:flutter_chat_kit/views/channel/file_message_item.dart';
import 'package:flutter_chat_kit/views/channel/message_input.dart';
import 'package:flutter_chat_kit/views/channel/no_audio_message_item.dart';
import 'package:flutter_chat_kit/views/channel/sender_avatar_view.dart';
import 'package:flutter_chat_kit/views/channel/text_field_voice_msg/text_voice_field.dart';
import 'package:flutter_chat_kit/views/channel/user_message_item.dart';
import 'package:flutter_chat_kit/views/channel/widgets/image_viewer.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sendbird_sdk/constant/command_type.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/message/admin_message.dart';
import 'package:sendbird_sdk/core/message/file_message.dart';
import 'package:sendbird_sdk/core/message/user_message.dart';
import 'package:sendbird_sdk/core/models/user.dart';

import '../../db_helper.dart';
import '../../di/service_locator.dart';
import '../../l10n/string_en.dart';
import '../../network/download_respository.dart';
import '../../widgets/splash_widget.dart';
import '../channel_list/channel_title_text_view.dart';
import 'chat_ad_details.dart';
import 'chat_app_bar.dart';
import 'disclaimer_message.dart';

class ChannelScreen extends StatefulWidget {
  final MainChannel channel;

  const ChannelScreen({required this.channel, Key? key}) : super(key: key);

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  late ChannelController controller;
  bool channelLoaded = false;

  @override
  void initState() {
    controller = ChannelController(widget.channel);
    controller.loadChannel().then((value) {
      setState(() {
        channelLoaded = true;
      });
      controller.loadMessages(reload: true);
    });
    super.initState();

    controller.updateChannelMessageReadCount();
  }

  @override
  void dispose() {
    controller.subscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ChatAppBar(user: widget.channel.getOtherChannelMember()),
          ),

            body: Obx(() => controller.isLoading.value && controller.messages.isEmpty
                ? const SplashWidget()
                : SafeArea(
                  child: controller.messages.isEmpty == true
                      ? const SplashWidget()
                      : Column(
                        children: [

                          ChatAdDetails(),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.5, vertical: 16),
                            child: DisclaimerMessage(),
                          ),

                          controller.isLoading.value
                          ? const CircularProgressIndicator() : const SizedBox.shrink(),

                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.itemCount,
                              controller: controller.lstController,
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              addRepaintBoundaries: false,
                              //cacheExtent: double.infinity,
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.only(top: 10, bottom: 10),

                              itemBuilder: (context, index) {


                                final message = controller.messages[index];
                                final prev = (index < controller.messages.length - 1)
                                    ? controller.messages[index + 1]
                                    : null;

                                final next = index == 0 ? null : controller.messages[index - 1];

                                if(message is MainMessage){

                                  if(message.type == CommandString.userMessage){

                                    return UserMessageItem(
                                      curr: message,
                                      prev: prev,
                                      next: next,
                                      model: controller,
                                      isMyMessage: message.isMyMessage,
                                      onPress: (pos) {},
                                      onLongPress: (pos) {},
                                    );

                                  }else if(message.type == CommandString.fileMessage){
                                    // Download Image
                                    if(message.mediaType == Strings.audioMediaType){

                                      return AudioChatBubbleWidget(
                                        message: message,
                                        key: Key(message.reqId.toString()),
                                        channelController: controller,
                                        channel: widget.channel,
                                        prev: prev,
                                        next: next,
                                        curr: message,
                                      );

                                    }else{

                                      return FileMessageItem(
                                        key: Key(message.msgId.toString()),
                                        curr: message,
                                        prev: prev,
                                        next: next,
                                        controller: controller,
                                        isMyMessage: message.isMyMessage,
                                        onPress: (pos) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ImageDialog(message: message),
                                              fullscreenDialog: true,
                                            ),);
                                        },
                                        onLongPress: (pos) {},
                                      );

                                    }
                                  }
                                }


                                else {
                                  //undefined message type
                                  return const SplashWidget();
                                }
                              },
                            ),
                          ),

                          TextVoiceField(
                            channelController: controller,
                            onSendMessage: (message) {
                              controller.onSendUserMessage(message);}
                          )
                      ],
                  )
                ),
            )
        );
  }


  User? getMemberUser() {
    return widget.channel.getOtherChannelMember();
  }


  Future<void> initDownloadIsolate(message, member) async {
    controller.saveFileInAppDirectory(message, member);
  }

}