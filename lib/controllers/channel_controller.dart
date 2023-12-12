import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/l10n/string_en.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/network/download_respository.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:flutter_chat_kit/utils/file_utils.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/constant/command_type.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/channel/base/base_channel.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:sendbird_sdk/core/message/user_message.dart';
import 'package:sendbird_sdk/core/models/sender.dart';
import 'package:sendbird_sdk/core/models/user.dart';
import 'package:sendbird_sdk/handlers/channel_event_handler.dart';
import 'package:sendbird_sdk/handlers/connection_event_handler.dart';
import 'package:sendbird_sdk/params/file_message_params.dart';
import 'package:sendbird_sdk/params/message_list_params.dart';
import 'package:sendbird_sdk/services/db/cache_service.dart';

import '../db_helper.dart';
import '../di/service_locator.dart';
import '../main.dart';
import '../utils/sendbird_constants.dart';
import '../views/channel/attachment_modal.dart';
import '../views/channel/message_item.dart';

enum UserEngagementState { typing, online, last_seen, none }

class ChannelController extends GetxController
    with ChannelEventHandler, ConnectionEventHandler {
  DBHelper dbHelper = getIt<DBHelper>();

  final RxList _messages = [].obs;
  GroupChannel? channel;
  late String channelUrl;

  StreamSubscription<ConnectivityResult>? subscription;

  bool hasNext = false;
  RxBool isLoading = false.obs;

  User? currentUser = getSendBirdLocalUser();

  Timer? _typingTimer;

  int get itemCount => _messages.length;

  bool get displayOnline => channel?.members.length == 2;

  Rx<UserEngagementState> get engagementState => UserEngagementState.none.obs;

  String? get lastSeenText {
    if (channel?.memberCount != 2) return null;
    final other =
        channel?.members.where((e) => e.userId != currentUser?.userId).first;
    final readStatus = channel?.getReadStatus(false);
    final receipt = readStatus?[other?.userId] ?? {};
    return (receipt['last_seen_at'] as int).readableLastSeen();
  }

  String get typersText {
    final users = channel?.getTypingUsers();
    if (users?.length == 1) {
      return '${users?.first.nickname} is typing...';
    } else if (users?.length == 2) {
      return '${users?.first.nickname} and ${users?.last.nickname} is typing...';
    } else if ((users?.length ?? 0) > 2) {
      return '${users?.first.nickname} and ${(users?.length ?? 0) - 1} more are typing...';
    }
    return '';
  }

  RxList get messages => _messages;

  final ScrollController lstController = ScrollController();

  ChannelController(this.channel) {
    channelUrl = channel?.channelUrl ?? "";
    sendbird.addChannelEventHandler('channel_listener', this);
    lstController.addListener(_scrollListener);
    // channel.markAsRead();
  }

  @override
  void dispose() async {
    super.dispose();
    subscription?.cancel();
    sendbird.removeChannelEventHandler('channel_listener');
    channel?.endTyping();
  }

  Future<void> loadChannel() async {
    // TODO: Reload channel again ...
    try {
      channel ??= await GroupChannel.getChannel(channelUrl);
      channel?.markAsRead();
    } catch (e) {
      if (kDebugMode) {
        //print(e.toString());
      }
    }
  }

  Future<void> loadMessages({
    int? timestamp,
    bool reload = false,
  }) async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    final ts = reload
        ? DateTime.now().millisecondsSinceEpoch
        : timestamp ?? DateTime.now().millisecondsSinceEpoch;

    try {
      var localMessages = await dbHelper.getChannelMessages(channelUrl, ts);
      if (localMessages.isNotEmpty == true) {
        List<dynamic> localList = [];
        for (var item in localMessages) {
          var message = MainMessage.fromDBResultSet(item);
          localList.add(message);
        }
        _messages.value.addAll(localList);
        isLoading.value = false;

      } else {
        final params = MessageListParams()
          ..isInclusive = false
          ..includeThreadInfo = true
          ..reverse = true
          ..previousResultSize = messagesPayloadRequestSize;
        final messages = await channel?.getMessagesByTimestamp(ts, params);

        var mainMessageList = MainMessage.fromBaseMessageList(messages);
        _messages.value = (reload ? mainMessageList : _messages.value + mainMessageList!)!;

        hasNext = mainMessageList?.length == messagesPayloadRequestSize;
        isLoading.value = false;

        // inserting in database;
        dbHelper.insertMessages(mainMessageList);
      }

      // Avoid push pending messages to server when we are scrolling up -> to load previous messages
      if(timestamp == 0 || timestamp == null) {
        pushPendingMessages();
      }

    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('group_channel_view.dart: getMessages: ERROR: $e');
      }
    }
  }

  void onTyping(bool hasText) {}

  MessageState getMessageState(BaseMessage message) {
    if (message.sendingStatus != MessageSendingStatus.succeeded) {
      return MessageState.none;
    }

    final readAll = channel?.getUnreadMembers(message).isEmpty;
    final deliverAll = channel?.getUndeliveredMembers(message).isEmpty;

    if (readAll == true) {
      return MessageState.read;
    } else if (deliverAll == true) {
      return MessageState.delivered;
    } else {
      return MessageState.none;
    }
  }

  Future<void> onSendUserMessage(String message, [bool deletePending = false, int localId = 0]) async {
    if (message == '') {
      return;
    }

    final preMessage = channel?.sendUserMessageWithText(message.trim(),
        onCompleted: (msg, error) async {

      if (error == null) {

        var mainMessage = MainMessage.fromBaseMessage(msg);

        if(localId == 0) {
          localId = _messages.firstWhere((element) => element.reqId == mainMessage.reqId).localId;
        }

        // Insert single message in db if succeeded
        dbHelper.insertMessage(mainMessage);

        final index = _messages.indexWhere((element) => (element.localId == localId || element.reqId == mainMessage.reqId));
        if (index != -1) {
          _messages.removeAt(index);
        }

        _messages.value = [mainMessage, ..._messages];
        _messages.sort((a, b) => b.ts.compareTo(a.ts));
        markAsReadDebounce();

        deleteMessageWithZeroId(mainMessage, deletePending, localId);


      }
    });


    if(preMessage != null && !deletePending){
      var mainMsg = MainMessage.fromBaseMessage(preMessage);
      (mainMsg).isMyMessage = true;
      int? id = await addMessageInDb(mainMsg);
      (mainMsg as MainMessage).localId = id;
      _messages.value = [mainMsg, ..._messages];
    }

    try{

      lstController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut,);

    }catch(e){
      if(kDebugMode){
        print(e.toString());
      }
    }
  }

  void onSendFileMessage(File file, [bool deletePending = false, int localId = 0]) async {
    final params = FileMessageParams.withFile(file);
    final preMessage = channel?.sendFileMessage(params, onCompleted: (msg, error) {

      if (error == null){
        var mainMessage = MainMessage.fromBaseMessage(msg);

        if(localId == 0) {
          localId = _messages.firstWhere((element) => element.reqId == mainMessage.reqId).localId;
        }

        final index = _messages.indexWhere((element) => (element.localId == localId || element.reqId == mainMessage.reqId));
        if (index != -1) {
          _messages.removeAt(index);
        }

        deleteMessageWithZeroId(mainMessage, deletePending, localId);

        // Insert single message in db if succeeded
        dbHelper.insertMessage(mainMessage);

        _messages.value = [mainMessage, ..._messages];
        _messages.sort((a, b) => b.ts.compareTo(a.ts));
        markAsReadDebounce();

      }

    });

    if(preMessage != null && !deletePending){
      var mainMsg = MainMessage.fromBaseMessage(preMessage) as MainMessage;
      var currentUser = getSendBirdLocalUser();
      mainMsg.isMyMessage = true;
      mainMsg.senderUserId = currentUser?.userId ?? "";
      mainMsg.senderProfileUrl = currentUser?.profileUrl;
      if(mainMsg.mediaType == Strings.audioMediaType) {
        (mainMsg).localFileUrl = file.path;
      }
      int? id = await addMessageInDb(mainMsg);
      mainMsg.localId = id;

      _messages.value = [mainMsg, ..._messages];

    }

    lstController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut,);
  }


  void markAsReadDebounce() {
    channel?.markAsRead();
  }


  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    if (channel.channelUrl != this.channel?.channelUrl) return;
    final index = _messages.indexWhere((e) => e.msgId == message.messageId.toString());
    var msg = MainMessage.fromBaseMessage(message);

    if (index != -1 && _messages.isNotEmpty) {
      // _messages.removeAt(index);
      // _messages[index] = msg;
    } else {
      _messages.insert(0, msg);
      //dbHelper.insertMessage(msg);
    }

    markAsReadDebounce();
  }


  _scrollListener() {
    if ((lstController.offset + 200) >= lstController.position.maxScrollExtent &&
        !lstController.position.outOfRange && !isLoading.value) {
      loadMessages(timestamp: _messages.last.timeStampInt,);
    }
    // if (lstController.offset <= lstController.position.minScrollExtent &&
    //     !lstController.position.outOfRange) {
    //   //reach bottom
    // }
  }


  Future<void> pushPendingMessages() async {
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if(result.isConnected){
        updateServerSyncing();
      }
    });

    if(isInternetConnected.value) {
      updateServerSyncing();
    }
  }

  updateServerSyncing() async {
    if(!isUserConnectedOnline.value){
      await makeConnectionRequest();
    }
    await updateLatestMessagesFromServer();
    uploadPendingMessages();
  }

  Future<void> uploadPendingMessages() async {
    // pushing unsent messages...
    var localMessages = await dbHelper.getMessagesWithZeroIds();
    if(localMessages.isNotEmpty == true){

      for (var item in localMessages) {
        var msg = MainMessage.fromDBResultSet(item);
        if (msg.sendingStatus == MessageSendingStatus.pending) {
          if(msg.type == CommandString.userMessage){
            onSendUserMessage(msg.message, true, msg.localId ?? 0);
          }else{
            if(msg.localFileUrl?.isNotEmpty == true){
              var file = File(msg.localFileUrl!);
              onSendFileMessage(file, true, msg.localId ?? 0);
            }
          }
        }
      }
    }

  }

  Future<int?> addMessageInDb(MainMessage? preMessage) async {
    var user = getSendBirdLocalUser();
    preMessage?.sender = Sender.fromUser(user, channel!);
    preMessage?.sendingStatus = MessageSendingStatus.pending;
    // Insert single message in db if succeeded
    return await dbHelper.insertMessage(preMessage);
  }

  Future<void> deleteMessageWithZeroId(MainMessage msg, bool deletePending, int localId) async {
    var localMessages = await dbHelper.getMessagesWithZeroIds();
    if(localMessages.isNotEmpty == true){
      for (var item in localMessages) {
        var message = MainMessage.fromDBResultSet(item);
        if(message.localId == localId){
          await dbHelper.deletePendingMessages(localId);

          // Removing from local list
          if(deletePending) {
            final index = _messages.indexWhere((element) => element.localId == localId && element.msgId == "0");
            if (index != -1) {
              _messages.removeAt(index);
            }
          }
        }
      }
    }
  }

  Future<void> updateLatestMessagesFromServer() async {
    try{

      final messages = await getMessagesFromServer();
      if(messages?.isNotEmpty == true){

        messages?.sort((a, b) => a.ts!.compareTo(b.ts!));
        dbHelper.insertMessages(messages);
        // updating local list with new messages received from server
        for (var msg in messages!) {
          if (!_messages.any((element) => (element as MainMessage).msgId == msg.msgId)) {
            _messages.insert(0, msg);
          }
        }
      }


    }catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
    }


  }

  Future<List<MainMessage>?> getMessagesFromServer() async {

    int payloadCount = messagesPayloadRequestSize;
    var isAnyMissedMsgFound = false;
    List<MainMessage> listOfMessages = [];
    var timeStampToGetFrom = DateTime.now().millisecondsSinceEpoch;

    do{
      isAnyMissedMsgFound = false;
      final params = MessageListParams()
        ..isInclusive = false
        ..includeThreadInfo = true
        ..reverse = true
        ..previousResultSize = payloadCount;
      final baseMessages = await channel?.getMessagesByTimestamp(timeStampToGetFrom, params);
      final messages = MainMessage.fromBaseMessageList(baseMessages);

      if(messages != null && messages.isNotEmpty){
        for(int i=0; i<messages.length; i++){
          var newTimeStamp = int.tryParse(messages[i].ts ?? "0") ?? 0;
          var currentTimeStamp = int.tryParse(_messages.first.ts ?? "0") ?? 0;

          if(newTimeStamp > currentTimeStamp){
            isAnyMissedMsgFound = true;
            listOfMessages.add(messages[i]);
          }
        }
        timeStampToGetFrom = int.tryParse(messages.last.ts ?? "0") ?? 0;
      } else{
        break;
      }
    } while(isAnyMissedMsgFound);

      return listOfMessages;
  }

  Future<void> showPlusMenu(BuildContext context) async {
    final modal = AttachmentModal(context: context);
    final file = await modal.getFile();
    if (file != null){
      onSendFileMessage(file);
    }
  }

  Future<String> saveFileInAppDirectory(MainMessage message, User? user) async {
    // Saving files to local
    var localFilePath = "";
    if(message.fileUrl?.isNotEmpty == true && !httpImageDownloadRequestsInQueue.contains(message.fileUrl)){

      httpImageDownloadRequestsInQueue.add(message.fileUrl ?? "");

      localFilePath = await getIt.get<DownloadRepository>().getDownloadFilePath(message, user);
      if(localFilePath.isNotEmpty == true && !((localFilePath).isDirectoryPath(user?.userId)) ){
        httpImageDownloadRequestsInQueue.remove(message.fileUrl);
        updateLocalMessageListWithLocalUrl(localFilePath, message);
        dbHelper.updateLocalFilePath(localFilePath, message.ts ?? "");
      }
    }
    
    return localFilePath;
  }

  void updateLocalMessageListWithLocalUrl(String localFilePath, MainMessage message) {
    for(int i=0; i<_messages.length; i++){
      var msg = _messages[i] as MainMessage;
      if(msg.msgId == message.msgId && (msg.localFileUrl?.isBlank == true)){
        msg.localFileUrl = localFilePath;
      }
    }
  }

  void updateChannelMessageReadCount() {
    dbHelper.updateChannelMsgReadCnt(channel?.channelUrl);
  }

}
