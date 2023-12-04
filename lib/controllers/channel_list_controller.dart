
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_kit/di/service_locator.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/utils/sendbird_constants.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/channel/base/base_channel.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:sendbird_sdk/core/models/user.dart';
import 'package:sendbird_sdk/handlers/channel_event_handler.dart';
import 'package:sendbird_sdk/handlers/connection_event_handler.dart';
import 'package:sendbird_sdk/query/channel_list/group_channel_list_query.dart';

import '../db_helper.dart';
import '../main.dart';

class ChannelListController extends GetxController with ChannelEventHandler{

  GroupChannelListQuery query = GroupChannelListQuery()..limit = messagesPayloadRequestSize;
  //User? currentUser = sendbird.currentUser;
  User? currentUser = getSendBirdLocalUser();

  RxList groupChannels = [].obs;

  RxBool isLoading = false.obs;
  DBHelper dbHelper = getIt<DBHelper>();

  // int get itemCount =>
  //     query.hasNext ? groupChannels.length + 1 : groupChannels.length;

  int get itemCount => groupChannels.length;

  String? destChannelUrl;

  bool get hasNext => query.hasNext;


  ChannelListController({this.destChannelUrl}) {
    sendbird.addChannelEventHandler('channel_list_view', this);
  }

  @override
  void dispose() {
    super.dispose();
    sendbird.removeChannelEventHandler('channel_list_view');
  }



  Future<void> loadChannelList({bool reload = false}) async {

    isLoading.value = true;

    if (kDebugMode) {
      print('loading channels...');
    }

    try {
      // Getting from DB

      var localChannelList = await dbHelper.getChannels();
      if(localChannelList.isNotEmpty){

        List<dynamic> localList = [];
        for(var item in localChannelList){
          var channel = MainChannel.fromDBResultSet(item);
          localList.add(channel);
        }

        isLoading.value = false;
        groupChannels.value = localList;

      }else{
        // Getting Online
        if (reload) {
          query = GroupChannelListQuery()
            ..limit = messagesPayloadRequestSize
            ..order = GroupChannelListOrder.latestLastMessage;
        }
        final res = await query.loadNext();

        var channelList = [];
        for (var grpChannel in res) {
          var mainChannel = MainChannel.fromJson(grpChannel.toJson());
          channelList.add(mainChannel);
        }

        isLoading.value = false;
        if (reload) {
          groupChannels.value = channelList;
        } else {
          groupChannels.value = [...groupChannels] + channelList;
        }

        // inserting in database;
        dbHelper.insertChannelList(res);
      }

    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('channel_list_view: getGroupChannel: ERROR: $e');
      }
    }
  }


  @override
  void onChannelChanged(BaseChannel channel) {
    if (channel is! GroupChannel) return;

    groupChannels.value = [...groupChannels];

    var mainChannel = MainChannel.fromJson(channel.toJson());

    final index = groupChannels.indexWhere((element) => element.channelUrl == mainChannel.channelUrl);

    if (index != -1) {
      groupChannels[index] = mainChannel;
    } else {
      groupChannels.insert(0, mainChannel);
    }
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    groupChannels.value = [...groupChannels];
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    if (channel is! GroupChannel) return;

    var mainChannel = MainChannel.fromJson(channel.toJson());

    groupChannels.value = [...groupChannels];

    final index = groupChannels.indexWhere((element) => element.channelUrl == mainChannel.channelUrl);

    if (index != -1) {
      groupChannels[index] = mainChannel;
    } else {
      groupChannels.insert(0, mainChannel);
    }


    // Proceed to add message in database when some other user sends a message (Because when connection is re-established then it listens even user itself sending a message not receiving)
    var localUser = getSendBirdLocalUser();
    if(localUser?.userId != message.sender?.userId){

      // Adding channel in database
      dbHelper.insertChannelList([channel]);

      // Adding message in database
      var channelMeta = jsonDecode(mainChannel.channelMeta?.toString() ?? "");
      if(channelMeta != null){
        var mainMessage = MainMessage.fromJson(channelMeta["last_message"]);
        dbHelper.insertMessage(mainMessage);
      }

    }

  }

  @override
  void onUserLeaved(GroupChannel channel, User user) {
    groupChannels.value = [...groupChannels];

    if (user.userId == currentUser?.userId) {
      final index = groupChannels
          .indexWhere((element) => element.channelUrl == channel.channelUrl);
      if (index != -1) {
        groupChannels.removeAt(index);
      }
    }
  }

  Future<void> loadChannel(channel) async {
    if( ((channel as MainChannel).unreadCount ?? 0) > 0){
      query = GroupChannelListQuery()..channelUrls = [channel.channelUrl]
        ..order = GroupChannelListOrder.latestLastMessage;
      final res = await query.loadNext();
      dbHelper.insertChannelList(res);
      //loadChannelList();
    }
  }

  void filterMessages(String query) {
    // Reset the filtered messages list
  }


}