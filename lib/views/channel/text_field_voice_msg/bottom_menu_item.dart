import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import '../../../../controllers/chat_text_voice_controller.dart';
import '../../../../l10n/string_en.dart';

import '../../../../utils/icon_constants.dart';
import '../../../controllers/channel_controller.dart';
import '../../../styles/colors.dart';
import '../../../styles/text_styles.dart';

class BottomMenuItems extends StatelessWidget {
  ChannelController channelController;
  BottomMenuItems({super.key,required this.channelController});
 
  ChatTextVoiceController chatTextVoiceController =
      Get.find<ChatTextVoiceController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  chatTextVoiceController.openGalleryCamera("Gallery",channelController);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.41,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: lightgreyColor6,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconConstants.galleryIconRed,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(Strings.gallery,
                            style: TextStyles.txtProximaNovaNormal16(
                                greyColor4))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.41,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: lightgreyColor6,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconConstants.locationIconRed,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(Strings.location,
                            style: TextStyles.txtProximaNovaNormal16(
                                greyColor4))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  chatTextVoiceController.openGalleryCamera("Camera",channelController);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.41,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: lightgreyColor6,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconConstants.cameraIconRed,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(Strings.camera,
                            style: TextStyles.txtProximaNovaNormal16(
                                greyColor4))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  chatTextVoiceController.openFileManager(channelController);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.41,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: lightgreyColor6,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconConstants.documentIconRed,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(Strings.document,
                            style: TextStyles.txtProximaNovaNormal16(
                                greyColor4))
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
