import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../../controllers/chat_text_voice_controller.dart';

import '../../../../utils/icon_constants.dart';
import '../../../controllers/channel_controller.dart';
import '../../../styles/colors.dart';
import '../../../styles/text_styles.dart';
import 'bottom_menu_item.dart';

class TextVoiceField extends StatelessWidget {
  final Function(String) onSendMessage;
  ChannelController channelController;

   TextVoiceField({Key? key, required this.onSendMessage,required this.channelController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    final ChatTextVoiceController chatTextVoiceController =
        Get.find<ChatTextVoiceController>();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            const SizedBox(
              height: 2,
              width: 4,
            ),
            Expanded(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
                child: Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: chatTextVoiceController.isRecording.value
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  if (chatTextVoiceController
                                      .isRecordingCompleted.value) {
                                    chatTextVoiceController.isRecording.value =
                                        false;
                                    chatTextVoiceController
                                        .isRecordingCompleted.value = false;
                                  } else {
                                    chatTextVoiceController.stopRecording();
                                    chatTextVoiceController.isRecording.value =
                                        false;
                                  }
                                },
                                child: SvgPicture.asset(
                                  IconConstants.deleteVoiceMsg,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const SizedBox(
                                width: 13,
                              ),


                              Obx(
                                  ()=> Text(
                                    chatTextVoiceController.formatDuration(
                                        chatTextVoiceController.elapsedDuration.value
                                    ),
                                    style: TextStyles.txtProximaNovaNormal16(
                                        greyColor7),
                                  ),
                              ),


                              const SizedBox(
                                width: 4,
                              ),
                              AudioWaveforms(
                                enableGesture: false,
                                size: Size(
                                    MediaQuery.of(context).size.width * 0.45,
                                    50),
                                recorderController:
                                    chatTextVoiceController.recorderController,
                                waveStyle: const WaveStyle(
                                  waveColor: skyblueColor3,
                                  extendWaveform: true,
                                  showMiddleLine: false,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: whiteColor,
                                  border: Border.all(
                                      color: lightRedColor,
                                      width: 2),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    if (chatTextVoiceController
                                        .isPaused.value) {
                                      chatTextVoiceController
                                          .startOrStopRecording(channelController);
                                    } else {
                                      chatTextVoiceController.pause();
                                    }
                                  },
                                  child: Center(
                                    child: Icon(
                                      chatTextVoiceController.isPaused.value
                                          ? Icons.play_arrow
                                          : Icons.pause,
                                      size: 14,
                                      color: lightRedColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : TextField(

                            controller:
                                chatTextVoiceController.textEditingController,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                              maxLines: 4,
                               minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              hintStyle: TextStyles.txtProximaNovaNormal14(
                                  greyColor6),

                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 14.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(94.0),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              suffixIcon: chatTextVoiceController
                                      .isTextEmpty.value
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            splashRadius: 20,
                                            icon: SvgPicture.asset(
                                              'assets/icons/attach_file_icon.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            onPressed: () {
                                              showMenu(
                                                elevation: 0,
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width),
                                                context: context,
                                                position: RelativeRect.fromLTRB(
                                                  0,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.69,
                                                  0,
                                                  0,
                                                ),
                                                items: [
                                                  PopupMenuItem(
                                                    child: BottomMenuItems(channelController: channelController,),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 10),
              child: Obx(
                () => GestureDetector(
                  child: chatTextVoiceController.isTextEmpty.value &&
                          !chatTextVoiceController.isRecording.value
                      ? SvgPicture.asset(
                          IconConstants.micIconTextField,
                          width: 23,
                          height: 23,
                        )
                      : SvgPicture.asset(
                          IconConstants.message_send_button,
                          width: 44,
                          height: 44,
                        ),
                  onTap: () {
                    if (!chatTextVoiceController.isTextEmpty.value &&
                        !chatTextVoiceController.isRecording.value) {
                      onSendMessage(
                          chatTextVoiceController.textEditingController.text);
                      chatTextVoiceController.textEditingController.clear();
                    } else {
                      chatTextVoiceController.startOrStopRecording(channelController);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
