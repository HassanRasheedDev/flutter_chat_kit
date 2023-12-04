import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import '../../models/message_model.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../utils/img_constants.dart';
import '../../widgets/circular_image.dart';

class AudioChatBubbleWidget extends StatefulWidget {
  final int? index;
  final MainMessage message;

  const AudioChatBubbleWidget({
    Key? key,
    required this.message,
    this.index,
  }) : super(key: key);

  @override
  State<AudioChatBubbleWidget> createState() => _AudioChatBubbleWidgetState();
}

class _AudioChatBubbleWidgetState extends State<AudioChatBubbleWidget> {
  File? file;

  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: skyblueColor3,
    liveWaveColor: whiteColor,
    spacing: 8,
    waveThickness: 4,
    showSeekLine: false,
  );

  @override
  void initState() {
    super.initState();


    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  void _preparePlayer() async {
    // Opening file from assets folder
    if (widget.index != null) {
      file = File(widget.message.localFileUrl ?? "");
      await file?.writeAsBytes(
          (await rootBundle.load('assets/audios/audio${widget.index}.mp3'))
              .buffer
              .asUint8List());
    }
    if (widget.index == null &&
        widget.message.localFileUrl == null &&
        file?.path == null) {
      return;
    }
    // Prepare player with extracting waveform if index is even.
    controller.preparePlayer(
      path: widget.message.localFileUrl ?? file!.path,
      shouldExtractWaveform: widget.index?.isEven ?? true,
    );
    // Extracting waveform separately if index is odd.
    if (widget.index?.isOdd ?? false) {
      controller
          .extractWaveformData(
            path: widget.message.localFileUrl ?? file!.path,
            noOfSamples: playerWaveStyle.getSamplesForWidth(300),
          )
          .then((waveformData) => debugPrint(waveformData.toString()));
    }
  }

  String get currTime => DateFormat('kk:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(widget.message.timeStampInt));

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print("---------build method-------- ${widget.message.localFileUrl}");

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: widget.message.isMyMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: widget.message.isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          widget.message.isMyMessage
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    CircularImageContainer(
                      height: 26,
                      width: 26,
                      imageUrl: widget.message.senderProfileUrl ??
                          ImageConstant.userImage,
                      placeHolder: ImageConstant.userImage,
                      radius: 50,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!controller.playerState.isStopped)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () async {
                                controller.playerState.isPlaying
                                    ? await controller.pausePlayer()
                                    : await controller.startPlayer(
                                        finishMode: FinishMode.loop,
                                      );
                              },
                              child: Icon(
                                controller.playerState.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: greyColor6,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(
                        width: 5,
                      ),
                      AudioFileWaveforms(
                        size: Size(MediaQuery.of(context).size.width / 2, 40),
                        playerController: controller,
                        waveformType: widget.index?.isOdd ?? false
                            ? WaveformType.fitWidth
                            : WaveformType.long,
                        playerWaveStyle: playerWaveStyle,
                      ),
                    ],
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
                      widget.message.isMyMessage
                          ? Icon(Icons.done_all,
                              color: widget.message.sendingStatus ==
                                      MessageSendingStatus.succeeded
                                  ? skyblueColor
                                  : greyColor4,
                              size: 16.0)
                          : const SizedBox.shrink(),
                    ],
                  )
                ],
              )),
          widget.message.isMyMessage
              ? Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    CircularImageContainer(
                      height: 28,
                      width: 28,
                      imageUrl: widget.message.senderProfileUrl ??
                          ImageConstant.userImage,
                      placeHolder: ImageConstant.userImage,
                      radius: 50,
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
}

/*
class AudioFileItem extends MessageItem {
  AudioFileItem({super.key,
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

  File? file;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: skyblueColor3,
    liveWaveColor: whiteColor,
    spacing: 8,
    waveThickness: 4,
    showSeekLine: false,
  );




  @override
  Widget get content =>  Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(mainContext).size.width * 0.7),
      padding: const EdgeInsets.only(
          left: 10.0, right: 10, top: 8, bottom: 3),
      decoration: BoxDecoration(
        color: lightgreyColor7,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!playerController.playerState.isStopped)
                Padding(
                  padding: const EdgeInsets.only(top:5.0),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: InkWell(
                      onTap: () async {
                        playerController.playerState.isPlaying == true
                            ? await playerController.pausePlayer()
                            : await playerController.startPlayer(
                          finishMode: FinishMode.loop,
                        );
                      },
                      child: Icon(
                        playerController.playerState.isPlaying == true
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: greyColor6,
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                width: 5,
              ),
              AudioFileWaveforms(
                size: Size(MediaQuery.of(mainContext).size.width / 2, 40),
                playerController: playerController,
                waveformType: WaveformType.long,
                playerWaveStyle: playerWaveStyle,
              ),
            ],
          ),
          const SizedBox(
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "11:05",
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
      ));

}

 */
