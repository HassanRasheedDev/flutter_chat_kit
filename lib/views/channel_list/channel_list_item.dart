import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:flutter_svg/svg.dart';

import 'package:sendbird_sdk/sendbird_sdk.dart';

import '../../main.dart';
import '../../styles/text_styles.dart';
import '../../utils/icon_constants.dart';
import '../../utils/img_constants.dart';
import '../channel/sender_avatar_view.dart';
import 'avatar_view.dart';
import 'channel_title_text_view.dart';

class ChannelListItem extends StatelessWidget {
  final MainChannel channel;
  final currentUserId = getSendBirdLocalUser()?.userId;

  ChannelListItem(this.channel, {super.key});

  @override
  Widget build(BuildContext context) {
    int lastDate = channel.getLastMessageTs();
    String lastMessageDateString = lastDate.readableTimestamp();

    return Container(
      color: (channel.unreadCount != null && channel.unreadCount! > 0) ? lightgreyColor5 : whiteColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  channel.isChannelActive == false
                      ? lightgreyColor
                      : Colors.transparent,
                  BlendMode.saturation,
                ),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: SenderAvatarView(
                    channelImageUrl: channel.channelImageUrl,
                    userId: channel.getOtherChannelMember()?.userId,
                    onPressed: () => (){},
                  )
                )
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          channel.recipientName ?? "-",
                          style: channel.isChannelActive == false
                              ? TextStyles.txtProximaNovaBold16(
                              lightgreyColor)
                              : TextStyles.txtProximaNovaBold16(
                            blackColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMessageDateString ?? "-",
                        style: channel.isChannelActive == false
                            ? TextStyles.txtProximaNovaNormal14(
                            lightgreyColor)
                            : TextStyles.txtProximaNovaNormal14(blackColor),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    channel.lastMessageText ?? "",
                    style: channel.isChannelActive == false
                        ? TextStyles.txtProximaNovaNormal14(lightgreyColor)
                        : (channel.unreadCount != null
                        ? TextStyles.txtProximaNovaExtraBold14(
                      blackColor,
                    )
                        : TextStyles.txtProximaNovaNormal14(blackColor)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(64),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    channel.isChannelActive == false
                                        ? lightgreyColor
                                        : Colors.transparent,
                                    BlendMode.saturation,
                                  ),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SenderAvatarView(
                                      channelImageUrl: channel.channelImageUrl,
                                      userId: channel.getOtherChannelMember()?.userId,
                                      onPressed: () => (){},
                                    ),
                                  )
                                ),
                              ),
                              channel.isChannelActive == true
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
                          Text(
                            channel.recipientName ?? "",
                            style: channel.isChannelActive == false
                                ? TextStyles.txtProximaNovaNormal14(
                                lightgreyColor)
                                : TextStyles.txtProximaNovaNormal14(
                                blackColor),
                          ),
                          channel.isVerified == true
                              ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SvgPicture.asset(
                              IconConstants.blueTick,
                              width: 12,
                              height: 12,
                            ),
                          )
                              : const SizedBox.shrink(),
                          const SizedBox(
                            width: 5,
                          ),
                          channel.rating != null
                              ? Row(
                            children: [
                              SizedBox(
                                height: 15,
                                child: VerticalDivider(
                                  color: dividerGreyColor
                                      .withOpacity(0.23),
                                  thickness: 1,
                                ),
                              ),
                              Icon(
                                Icons.star,
                                color:
                                dividerGreyColor.withOpacity(0.23),
                                size: 16,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                channel.rating.toString(),
                                style:
                                TextStyles.txtProximaNovaNormal14(
                                    blackColor),
                              ),
                            ],
                          )
                              : const SizedBox.shrink(),
                          channel.isChannelActive == false
                              ? Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: SvgPicture.asset(
                              IconConstants.issueIcon,
                              width: 9,
                              height: 12,
                            ),
                          )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      channel.unreadCount != null && channel.unreadCount! > 0
                          ? Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Center(
                          child: Text(
                            channel.unreadCount.toString(),
                            style: TextStyles.txtProximaNovaBold12(
                                whiteColor),
                          ),
                        ),
                      )
                          : const SizedBox.shrink()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );


  }

}
