import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_kit/main.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:flutter_chat_kit/views/channel/sender_avatar_view.dart';
import 'package:flutter_chat_kit/views/channel/widgets/audio_place_holder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/models/user.dart';
import '../../controllers/channel_controller.dart';
import '../../models/message_model.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../utils/img_constants.dart';
import '../../widgets/circular_image.dart';
import 'no_audio_message_item.dart';

class AudioChatBubbleWidget extends StatelessWidget {

  final int? index;
  final MainMessage message;
  final ChannelController channelController;
  final MainChannel channel;
  final MainMessage? curr;
  final MainMessage? prev;
  final MainMessage? next;

  AudioChatBubbleWidget({
    Key? key,
    required this.message,
    this.prev,
    this.next,
    this.curr,
    required this.channelController,
    required this.channel,
    this.index,
  }) : super(key: key);
  
  

  File? file;

  PlayerController? controller;
  StreamSubscription<PlayerState>? playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: skyblueColor3,
    liveWaveColor: whiteColor,
    spacing: 8,
    waveThickness: 4,
    showSeekLine: false,
  );

  RxBool isControllerInitilised = false.obs;
  RxBool isFileLoading = false.obs;
  RxBool isPlayerPlaying = false.obs;

  

  @override
  Widget build(BuildContext context) {
    print("---------build method-------- ${message.localFileUrl}");

    var user = getSendBirdLocalUser();

    return Obx(() => isFileLoading.value == true
        ? NoAudioMessageItem(
        prev: prev,
        next: next,
        curr: message,
        isMyMessage: message.isMyMessage,
        model: channelController) : buildAudioContent(context, user)

    );
  }

  Widget buildAudioContent(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: message.isMyMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: message.isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          message.isMyMessage
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    const SizedBox(
                      width: 8,
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: SenderAvatarView(
                        channelImageUrl: user?.profileUrl,
                        userId: message.senderUserId,
                        width: 26,
                        height: 26,
                        onPressed: () => (){},
                      ),
                    ),

                    const SizedBox(
                      width: 14,
                    ),
                  ],
                ),
          Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10, top: 8, bottom: 3),
              decoration: BoxDecoration(
                color: lightgreyColor7,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Obx(() => isControllerInitilised.value
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //if (!(playerState?.value.isStopped == true))
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if(isPlayerPlaying.value == true){
                                        await controller?.pausePlayer();
                                        isPlayerPlaying.value = false;
                                      }else{
                                        await controller?.startPlayer(finishMode: FinishMode.loop,);
                                        isPlayerPlaying.value = true;
                                      }
                                    },
                                    child: Obx(() => isPlayerPlaying.value == true

                                        ?  const Icon(Icons.pause,
                                          color: greyColor6,
                                        ): const Icon(Icons.play_arrow,
                                          color: greyColor6,
                                        )
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(
                              width: 5,
                            ),
                            AudioFileWaveforms(
                              size: Size(
                                  MediaQuery.of(context).size.width / 2, 40),
                              playerController: controller!,
                              waveformType: index?.isOdd ?? false
                                  ? WaveformType.fitWidth
                                  : WaveformType.long,
                              playerWaveStyle: playerWaveStyle,
                            ),
                          ],
                        )
                      : AudioPlaceHolder(() { 
                        attachFileToPlayer();
                      }, key: Key(message.ts??""),)
                  ),


                  const SizedBox(
                    height: 1,
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


                      message.isMyMessage
                          ? (Icon(message.sendingStatusIcon,
                          color: greyColor4,
                          size: 16.0)

                      ) : const SizedBox.shrink()

                    ],
                  )
                ],
              )),

          message.isMyMessage
              ? Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: SenderAvatarView(
                        channelImageUrl: message.senderProfileUrl ?? "",
                        userId: message.senderUserId,
                        width: 26,
                        height: 26,
                        onPressed: () => (){},
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),
                  ],
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Future<void> attachFileToPlayer() async {
    isFileLoading.value = true;
    controller = PlayerController();
    if (message.localFileUrl?.isNotEmpty == true) {
      file = File(message.localFileUrl!.toString());
    } else {
      var _file = await channelController.saveFileInAppDirectory(
          message, channel.getOtherChannelMember());
      file = File(_file);
      message.localFileUrl = _file;
    }

    if (controller != null) {
      _preparePlayer();
      playerStateSubscription = controller!.onPlayerStateChanged.listen((_) {
        isPlayerPlaying.value = controller?.playerState.isPlaying ?? false;
      });
      isControllerInitilised.value = true;
    }
    isPlayerPlaying.value = controller?.playerState.isPlaying ?? false;
    isFileLoading.value = false;

  }

  void _preparePlayer() async {
    // Prepare player with extracting waveform if index is even.
    controller?.preparePlayer(
      path: message.localFileUrl ?? file!.path,
      shouldExtractWaveform: index?.isEven ?? true,
    );
  }

  String get currTime => DateFormat('kk:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(message.timeStampInt));



  @override
  void dispose() {
    playerStateSubscription?.cancel();
    controller?.dispose();
    isControllerInitilised.value = false;
  }
}
