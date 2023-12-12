import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:flutter_chat_kit/main.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mime/mime.dart';
import 'package:sendbird_sdk/constant/command_type.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import '../l10n/string_en.dart';
import 'message_contants_enum.dart';

class MainMessage extends BaseMessage{

  int? localId;
  String? type;
  String? custom;
  String? ts;
  String? msgId;
  String? reqId;
  String? messageMeta;
  String? fileUrl;
  String? localFileUrl;
  String? mediaType;
  String? senderProfileUrl;
  String? senderUserId;

  bool isMyMessage;


  MainMessage({
    required super.isPinnedMessage,
    required super.message,
    required super.sendingStatus,
    required super.channelUrl,
    required super.channelType,
    this.type,
    this.localId,
    this.custom,
    this.msgId,
    this.reqId,
    this.ts,
    this.messageMeta,
    this.fileUrl,
    this.mediaType,
    this.localFileUrl,
    this.isMyMessage = false,
    this.senderProfileUrl,
    this.senderUserId
  });


  // Local File => if app is uploading file then there must be some local path
  factory MainMessage.fromJson(Map<String, dynamic> jsn, [File? localFile]){

    var json = getJsonWithExtraFields(jsn);
    var messageText = getMessageText(json);
    var fileUrl = getMessageFileUrl(json);
    var mediaType = getMediaFileType(json);
    var isMyMessage = getIfThisIsCurrentUserMessage(json);
    var senderProfileUrl = getSenderProfileUrl(json);
    var senderUserId = getSenderUserId(json);

    return MainMessage(
        isPinnedMessage: json["is_pinned_message"],
        message: messageText,
        sendingStatus: $enumDecodeNullable(MessageSendingStatusEnumMap, json['sending_status']),
        channelUrl: json["channel_url"],
        channelType: $enumDecode(ChannelTypeEnumMap, json['channel_type']),
        type: json["type"],
        msgId:  json["message_id"].toString(),
        custom:  json["data"],
        reqId:  json["request_id"],
        ts:  json["created_at"].toString(),
        messageMeta: jsonEncode(json),
        fileUrl: fileUrl,
        mediaType: mediaType,
        localFileUrl: localFile?.path,
        isMyMessage: isMyMessage,
        senderProfileUrl: senderProfileUrl,
        senderUserId: senderUserId,
    );
  }

  get localFile => localFileUrl != null ? File(localFileUrl ?? "") : null;

  String? get secureUrl {
    return '$fileUrl?auth=$authenticationKey';
  }

  int get timeStampInt => int.tryParse(ts ?? "0") ?? 0;

  IconData? get sendingStatusIcon => sendingStatus == MessageSendingStatus.pending ? Icons.access_time_outlined
  : (sendingStatus == MessageSendingStatus.succeeded ? Icons.done_all : Icons.done_rounded);

  @override
  Map<String, dynamic> toJson() {

    var sendStatus = MessageSendingStatus.values.firstWhere((element) => element == sendingStatus);
    var chnlType = ChannelType.values.firstWhere((element) => element == channelType);

    return {
      "channel_url": channelUrl,
      "message_id": msgId,
      "message_ts": ts,
      "message_meta": messageMeta,
      "type": type,
      "custom": custom,
      "request_id": reqId,
      "message": message,
      "file_url": fileUrl,
      "media_type": mediaType,
      "sending_status": sendStatus.name,
      "channel_type": chnlType.name,
      "local_file_url": localFileUrl,
      "is_my_message": isMyMessage == true ? 1 : 0,
      "sender_profile_url": senderProfileUrl,
      "sender_user_id": senderUserId
    };
  }


  static getMessageType(json) {
    if (json["message"] != null && json["message"] != "" &&
        (json["url"] == null || json["url"] == "")) {
      return CommandString.userMessage;
    } else {
      return CommandString.fileMessage;
    }
  }

  static getMessageText(Map<String, dynamic> json) {
    var message = BaseMessage.fromJson(json);
    if(message is FileMessage){
      return message.name ?? "";
    }else{
      return message.message;
    }
  }

  static getMessageFileUrl(json) {
    var message = BaseMessage.fromJson(json);
    if(message is FileMessage){
      return message.url ?? "";
    }else{
      return "";
    }
  }

  static getMediaFileType(json) => json["media_type"] ?? "";

  static getJsonWithExtraFields(Map<String, dynamic> json) {
    var messageType = getMessageType(json);
    json["custom"] = json['data'];
    if(json["media_type"] == null) {
      json["media_type"] = json['type'];
    }
    json["type"] = messageType;
    json["ts"] = json['created_at'];
    json["msg_id"] = json['message_id'];
    json["req_id"] = json['request_id'];
    return json;
  }

  static fromDBResultSet(Map<String, Object?> json) {

    return MainMessage(
        isPinnedMessage: false,
        message: json["message"] != null ? json["message"].toString() : "",
        sendingStatus: $enumDecodeNullable(MessageSendingStatusEnumMap, json['sending_status']),
        channelUrl: json["channel_url"] != null ? json["channel_url"].toString() : "",
        channelType: $enumDecode(ChannelTypeEnumMap, json['channel_type']),
        messageMeta: json["message_meta"] != null ? json["message_meta"].toString() : "",
        msgId: json["message_id"] != null ? json["message_id"].toString() : "0",
        ts: json["message_ts"] != null ? json["message_ts"].toString() : "0",
        type: json["type"] != null ? json["type"].toString() : "",
        reqId: json["request_id"] != null ? json["request_id"].toString() : "",
        fileUrl: json["file_url"] != null ? json["file_url"].toString() : "",
        mediaType: json["media_type"] != null ? json["media_type"].toString() : "",
        isMyMessage: json["is_my_message"] != null ? (json["is_my_message"] == 1 ? true : false) : false,
        senderProfileUrl: json["sender_profile_url"] != null ? json["sender_profile_url"].toString() : "",
        senderUserId: json["sender_user_id"] != null ? json["sender_user_id"].toString() : "",
        localFileUrl: json["local_file_url"] != null ? json["local_file_url"].toString() : "",
        localId: json["id"] != null ? (int.tryParse(json["id"].toString()) ?? 0) : 0,
    );

  }

  static fromBaseMessageList(List<BaseMessage>? messages) {

    List<MainMessage> list = [];
    if(messages?.isNotEmpty == true){
      for(int  i=0; i<(messages!.length); i++){
        list.add(MainMessage.fromJson(messages[i].toJson()));
      }
    }
    return list;
  }

  static fromBaseMessage(message){
    if(message is FileMessage){
      var json = message.toJson();
      json["media_type"] = lookupMimeType(message.localFile?.path ?? "");
      return MainMessage.fromJson(json, message.localFile);

    }else{
      return MainMessage.fromJson(message.toJson());
    }

  }

  static getIfThisIsCurrentUserMessage(json) {
    if(json["user"] != null){
      var user = User.fromJson(json["user"]);
      if(user.userId == getSendBirdLocalUser()?.userId){
        return true;
      }
    }
    return false;
  }

  static getSenderProfileUrl(json) {
    if(json["user"] != null){
      return User.fromJson(json["user"]).profileUrl ?? "";
    }
    return "";
  }

  static getSenderUserId(json) {
    if(json["user"] != null){
      return User.fromJson(json["user"]).userId ?? "";
    }
    return "";
  }

}