import 'dart:convert';

import 'package:flutter_chat_kit/main.dart';
import 'package:flutter_chat_kit/views/channel_list/channel_title_text_view.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:sendbird_sdk/core/message/file_message.dart';
import 'package:sendbird_sdk/core/models/member.dart';
import 'package:sendbird_sdk/core/models/user.dart';
import 'package:sendbird_sdk/utils/json_from_parser.dart';

import 'message_model.dart';

class MainChannel extends GroupChannel {
  String? lastMessageTs;
  String? channelMeta;
  String? recipientName;
  String? lastMessageText;
  String? channelName;
  String? rating;
  String? lastActivityTs;
  int? unreadCount;
  bool? isVerified;
  bool? isChannelActive;

  String? channelCreatedAt;
  String? channelImageUrl;

  MainChannel(
      {required super.channelUrl,
      this.lastActivityTs,
      this.channelMeta,
      this.recipientName,
      this.lastMessageText,
      this.channelName,
      this.rating,
      this.lastMessageTs,
      this.unreadCount,
      this.isVerified,
      this.isChannelActive,
      this.channelCreatedAt,  this.channelImageUrl});

  factory MainChannel.fromJson(Map<String, dynamic> json) {
    var lastReceivedMessage = getLastMessageFromJson(json);
    var recipientName = getRecipientName(json);
    var channelImgUrl = getChannelImageUrl(json);

    return MainChannel(
        channelUrl: json["channel_url"],
        lastActivityTs: lastReceivedMessage?.ts.toString(),
        channelMeta: jsonEncode(json),
        channelName: json["name"],
        recipientName: recipientName,
        isChannelActive: json["is_strict"] != null ?  json["is_strict"] == false : false,
        isVerified: json["is_strict"] != null ?  json["is_strict"] == false : false,
        lastMessageText: lastReceivedMessage?.message ?? "",
        lastMessageTs: lastReceivedMessage?.ts.toString(),
        rating: "5.0",
        unreadCount: json["unread_message_count"],
        channelImageUrl: channelImgUrl,
        channelCreatedAt: json["created_at"] != null ? json["created_at"].toString() : "0");
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "channel_url": channelUrl,
      "last_activity_ts": lastActivityTs,
      "channel_meta": channelMeta,
      "channel_name": channelName,
      "recipient_name": recipientName,
      "is_channel_active": true ? 1 : 0,
      "is_verified": true ? 1 : 0,
      "last_message_text": lastMessageText,
      "last_message_ts": lastMessageTs,
      "rating": "5.0",
      "unread_count": unreadCount,
      "channel_image_url": channelImageUrl,
      "createdAt": channelCreatedAt?.toString()
    };
  }

  static String getRecipientName(Map<String, dynamic> json) {
    var currentUserId = getSendBirdLocalUser()?.userId ?? 0;
    var recipientName = "";
    List<String> namesList = [
      for (final member in json["members"])
        if (User.fromJson(member).userId != currentUserId)
          User.fromJson(member).nickname
    ];
    recipientName = namesList.join(", ");
    return recipientName;
  }

  static getMessageType(json) {
    if (json["message"] != null && json["message"] != "") {
      return "MESG";
    } else {
      return "FILE";
    }
  }

  static getLastMessageFromJson(Map<String, dynamic> json) {
    return MainMessage.fromJson(json["last_message"]);
  }

  factory MainChannel.fromDBResultSet(Map<String, Object?> item) {
    return MainChannel(
      channelUrl:
          item["channel_url"] != null ? item["channel_url"].toString() : "",
      lastActivityTs: item["last_message_ts"] != null
          ? item["last_message_ts"].toString()
          : "",
      channelMeta:
          item["channel_meta"] != null ? item["channel_meta"].toString() : "",
      channelName:
          item["channel_name"] != null ? item["channel_name"].toString() : "",
      recipientName: item["recipient_name"] != null
          ? item["recipient_name"].toString()
          : "",
      isChannelActive: item["is_channel_active"] != null
          ? (item["is_channel_active"] == "1" ? true : false)
          : false,
      isVerified: item["is_verified"] != null
          ? (item["is_verified"] == "1" ? true : false)
          : false,
      lastMessageText: item["last_message_text"] != null
          ? item["last_message_text"].toString()
          : "",
      lastMessageTs: item["last_message_ts"] != null
          ? item["last_message_ts"].toString()
          : "",
      rating: item["rating"] != null ? item["rating"].toString() : "",
      unreadCount: item["unread_count"] != null
          ? (int.tryParse(item["unread_count"]?.toString() ?? "0") ?? 0)
          : 0,
      channelCreatedAt:
          item["createdAt"] != null ? item["createdAt"].toString() : "",
      channelImageUrl: item["channel_image_url"] != null ? item["channel_image_url"].toString() : "",

    );
  }

  static String getChannelImageUrl(Map<String, dynamic> json) {
    var currentUserId = getSendBirdLocalUser()?.userId ?? 0;
    var recipientImageUrl = "";

    for (final member in json["members"]){
      if (User.fromJson(member).userId != currentUserId){
        recipientImageUrl = User.fromJson(member).profileUrl ?? "";
      }
    }
    return recipientImageUrl;
  }

  int getLastMessageTs() {

    if(lastMessageTs != null){
      return int.tryParse(lastMessageTs!) ?? 0;
    }else{
     return createdAt ?? 0;
    }

  }

  User? getOtherChannelMember() {

    if(channelMeta != null){
      var channelMetaJson = jsonDecode(channelMeta!);
      var currentUser = getSendBirdLocalUser();

      for(int i=0; i<channelMetaJson["members"].length; i++){
        if(channelMetaJson["members"][i]["user_id"] != currentUser?.userId){
          return User.fromJson(channelMetaJson["members"][i]);
        }
      }
    }
    return null;
  }

}
