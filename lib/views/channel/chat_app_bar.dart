import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/views/channel/sender_avatar_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sendbird_sdk/core/models/user.dart';

import '../../../l10n/string_en.dart';
import '../../../models/user_model.dart';
import '../../../utils/icon_constants.dart';
import '../../../utils/img_constants.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({super.key, required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        splashRadius: 18,
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 19,
          color: buttonGreyColor,
        ),
      ),
      leadingWidth: 40,
      actions: [
        PopupMenuButton<String>(
          offset: const Offset(0, 55),
          splashRadius: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          icon: const Icon(
            Icons.more_vert,
            size: 22,
            color: buttonGreyColor,
          ),
          onSelected: (String value) {
            if (kDebugMode) {
              print("Selected option: $value");
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'Pin Chat',
              child: Text(
                'Pin Chat',
                style:
                    TextStyles.txtProximaNovaNormal16(greyColor4),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Rate User',
              child: Text(
                'Rate User',
                style:
                TextStyles.txtProximaNovaNormal16(greyColor4),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Block User',
              child: Text(
                'Block User',
                style:
                TextStyles.txtProximaNovaNormal16(greyColor4),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Report and Block',
              child: Text(
                'Report and Block',
                style:
                TextStyles.txtProximaNovaNormal16(greyColor4),
              ),
            ),
          ],
        ),
      ],
      title: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(64),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: SenderAvatarView(
                    channelImageUrl: user?.profileUrl ?? "",
                    userId: user?.userId,
                    onPressed: () => (){},
                  ),
                )


              ),
              user?.isActive == true
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      child: SvgPicture.asset(
                        IconConstants.onlineIcon,
                        width: 12,
                        height: 12,
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user?.nickname ?? "",
                        style: TextStyles.txtProximaNovaBold16(
                            appBarTextGreyColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    user?.isActive == true
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SvgPicture.asset(
                              IconConstants.blueTick,
                              width: 12,
                              height: 12,
                            ),
                          )
                        : const SizedBox.shrink(),
                    user?.isActive != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              width: 45,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: greyColor3,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: greyColor4,
                                    size: 16,
                                  ),
                                  const SizedBox(
                                    width: 1,
                                  ),
                                  Text(
                                    "4.5",
                                    style: TextStyles.txtProximaNovaNormal12(
                                        greyColor2),
                                  ),
                                ],
                              ),
                            ))
                        : const SizedBox.shrink()
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Text("${Strings.lastSeen} ${user?.lastSeenAt}",
                    style: TextStyles.txtProximaNovaNormal12(
                        appBarTextGreyColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreenDropDown extends StatelessWidget {
  final Function(String) onOptionSelected;

  const ChatScreenDropDown({required this.onOptionSelected, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156.0,
      height: 160.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        onChanged: (String? newValue) {
          if (newValue != null) {
            onOptionSelected(newValue);
          }
        },
        items: <String>[
          'Pin Chat',
          'Rate User',
          'Block User',
          'Report and Block'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(value),
            ),
          );
        }).toList(),
      ),
    );
  }
}
