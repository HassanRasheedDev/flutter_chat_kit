import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/controllers/channel_controller.dart';
import 'package:flutter_chat_kit/main.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/views/channel/audio_file_item.dart';
import 'package:flutter_chat_kit/views/channel/file_message_item.dart';
import 'package:flutter_chat_kit/views/channel/message_input.dart';
import 'package:flutter_chat_kit/views/channel/no_audio_message_item.dart';
import 'package:flutter_chat_kit/views/channel/sender_avatar_view.dart';
import 'package:flutter_chat_kit/views/channel/text_field_voice_msg/text_voice_field.dart';
import 'package:flutter_chat_kit/views/channel/user_message_item.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sendbird_sdk/constant/command_type.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/message/admin_message.dart';
import 'package:sendbird_sdk/core/message/file_message.dart';
import 'package:sendbird_sdk/core/message/user_message.dart';
import 'package:sendbird_sdk/core/models/user.dart';

import '../../l10n/string_en.dart';
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

                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.itemCount,
                              controller: controller.lstController,
                              reverse: true,
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

                                      return FutureBuilder<String>(
                                        future: controller.saveFileInAppDirectory(message, widget.channel.getOtherChannelMember()),
                                        builder: (context, snapshot) {

                                          if(snapshot.connectionState == ConnectionState.done && snapshot.data != null){
                                            message.localFileUrl = snapshot.data.toString();
                                            return AudioChatBubbleWidget(message: message);
                                          }else{
                                            return NoAudioMessageItem(
                                                prev: prev,
                                                next: next,
                                                curr: message,
                                                isMyMessage: message.isMyMessage,
                                                model: controller);
                                          }
                                        },
                                      );

                                    }else{
                                      controller.saveFileInAppDirectory(message, widget.channel.getOtherChannelMember());
                                      return FileMessageItem(
                                        curr: message,
                                        prev: prev,
                                        next: next,
                                        controller: controller,
                                        isMyMessage: message.isMyMessage,
                                        onPress: (pos) {
                                          //
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

                          // MessageInput(
                          //     onPressSend: (text){
                          //         if(!controller.isLoading.value){
                          //           controller.onSendUserMessage(text);
                          //         }
                          //       }, onChanged: (text){
                          //         controller.onTyping(text != '');
                          //     },
                          //       onPressPlus: () {
                          //       controller.showPlusMenu(context);
                          //
                          //   },)

                      ],
                  )
                ),
            )
        );
  }


  User? getMemberUser() {
    return widget.channel.getOtherChannelMember();
  }

  Widget _buildTitle(BuildContext context, UserEngagementState ue) {

    var member = getMemberUser();
    List<Widget> headers = [
              SenderAvatarView(
                channelImageUrl: widget.channel.channelImageUrl,
                userId: member?.userId ?? "",
                width: 36,
                height: 36,
                onPressed: () => (){},
              ),
      const SizedBox(width: 4),
    ];

    headers.add( Text(widget.channel.recipientName ?? "",
      maxLines: 1,
      style: Theme.of(context).textTheme.titleSmall,
      overflow: TextOverflow.ellipsis,
    ));

    // switch (ue) {
    //   case UserEngagementState.typing:
    //     headers.addAll([
    //       const SizedBox(height: 3),
    //       Text(
    //         controller.typersText,
    //         style: Theme.of(context).textTheme.titleSmall,
    //       )
    //     ]);
    //     break;
    //   default:
    //     break;
    // }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: headers,
    );
  }
}



/*
  appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: _buildTitle(context, controller.engagementState.value),
          ),
 */