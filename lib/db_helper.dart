
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_kit/l10n/string_en.dart';
import 'package:flutter_chat_kit/models/message_model.dart';
import 'package:flutter_chat_kit/utils/message_json_mapper.dart';
import 'package:flutter_chat_kit/utils/sendbird_constants.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:sqflite/sqflite.dart';

import 'models/channel_model.dart';

class DBHelper{

  Database? _db;
  final int _version = 1;
  final String _channelTableName = 'channel';
  final String _chatsTableName = 'chats';

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database?> initDb() async {

    try {
      String path = '${await getDatabasesPath()}_sendbird_chat.db';
      _db = await openDatabase(path,
          version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);

      if (kDebugMode) {
        print('Database created =========');
      }
    } catch (e) {
      if (kDebugMode) {
        print('initDb Method Error! = $e');
      }
    }
    return _db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        // Channel Table creation
        'CREATE TABLE $_channelTableName'
            '(last_message_ts TEXT,'
            'createdAt TEXT PRIMARY KEY,'
            'channel_url TEXT,'
            'last_activity_ts TEXT,'
            'channel_name TEXT,'
            'recipient_name TEXT,'
            'is_channel_active TEXT,'
            'is_verified TEXT,'
            'last_message_text TEXT,'
            'rating TEXT,'
            'unread_count TEXT,'
            'channel_image_url TEXT,'
            'channel_meta TEXT'
            ');'
    );

    await db.execute(
      // Channel Table creation
        'CREATE TABLE $_chatsTableName'
            '(id INTEGER PRIMARY KEY AUTOINCREMENT,' // id => local id to maintain data in case of local caching
            'message_id TEXT,'
            'channel_url TEXT,'
            'message_ts TEXT,'
            'message_meta TEXT,'
            'type TEXT,'
            'custom TEXT,'
            'request_id TEXT,'
            'message TEXT,'
            'file_url TEXT,'
            'local_file_url TEXT,'
            'media_type TEXT,'
            'sending_status TEXT,'
            'channel_type TEXT,'
            'is_my_message INTEGER,'
            'sender_profile_url TEXT,'
            'sender_user_id TEXT'
            ');'
    );
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (kDebugMode) {
      print('onUpgrade ====================================\n');
    }
  }

  insertChannelList(List<dynamic> channelList) async{

    Database? mydb = await db;
    if (kDebugMode) {
      print('Insert ====');
    }

    Batch? batch = mydb?.batch();
    for(var item in channelList) {
      var mainChannel = MainChannel.fromJson(item.toJson());
      var valueMap = mainChannel.toJson();
      batch?.insert(_channelTableName, valueMap, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch?.commit(noResult: true);

  }

  Future<List<Map<String, Object?>>> getChannels() async{
    Database? mydb = await db;
    if (kDebugMode) {
      print('Query getChannels ====');
    }
    return await mydb!.query(_channelTableName, orderBy: "last_message_ts DESC");
  }

  insertMessages(List<MainMessage>? messages) async{

    Database? mydb = await db;
    if (kDebugMode) {
      print('Insert ====');
    }
    Batch? batch = mydb?.batch();
    for(var item in messages ?? []) {
      //var values = MainMessage.fromJson(item.toJson());
      var valueMap = item.toJson();
      batch?.insert(_chatsTableName, valueMap, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch?.commit(noResult: true);
  }

  Future<int?> insertMessage(MainMessage? message) async{
    Database? mydb = await db;
    if (kDebugMode) {
      print('Insert ====');
    }
    // var values = MainMessage.fromJson(message.toJson());
    var valueMap = message?.toJson() ?? {};
    return await mydb?.insert(_chatsTableName, valueMap);
  }

  Future<List<Map<String, Object?>>> getChannelMessages(String channelUrl,[ int timestamp = 0]) async{
    Database? mydb = await db;
    if (kDebugMode) {
      print('Query getChannelMessages ====');
    }
    if(timestamp == 0){
      timestamp = DateTime.now().millisecondsSinceEpoch;
    }
    return await mydb!.query(_chatsTableName,
        where: "channel_url = ? and message_ts < ?",
        whereArgs: [channelUrl, timestamp],
        orderBy: "message_ts DESC", limit: messagesPayloadRequestSize
    );
  }

  Future<List<Map<String, Object?>>> getChannelPendingMessages(String channelUrl) async {
    Database? mydb = await db;
    if (kDebugMode) {
      print('Query getChannelPendingMessages ====');
    }
    return await mydb!.query(_chatsTableName,
        where: "channel_url = ? and message_id = 0",
        whereArgs: [channelUrl],
        orderBy: "message_ts DESC"
    );
  }

  getMessageMap(BaseMessage item) {
    var messageId = item.messageId.toString();
    var channelUrl = item.channelUrl.toString();
    var messageTs = item.createdAt.toString();
    var payload = jsonEncode(BaseMessageJsonMapper.getPreProcessedMsgJson(item.toJson()));
    return {
      "message_id":messageId,
      "channel_url":channelUrl,
      "message_ts":messageTs,
      "payload":payload
    };

  }

  Future<int> deletePendingMessages(int localId) async {
    Database? mydb = await db;
    if (kDebugMode) {
      print('Query deletePendingMessages ====');
    }
    return await mydb!.delete(_chatsTableName,
        where: "id = ?",
        whereArgs: [localId],
    );
  }

  Future<List<Map<String, Object?>>> getMessagesWithZeroIds() async {

    Database? mydb = await db;
    if (kDebugMode) {
      print('Query getMessagesWithZeroIds ====');
    }
    return await mydb!.query(_chatsTableName,
      where: "message_id = 0"
    );

  }

  Future<int> updateLocalFilePath(String localFilePath, String messageTs) async {
    Database? mydb = await db;
    if (kDebugMode) {
      print('Update local path ====');
    }
    return await mydb!.rawUpdate(
        'Update $_chatsTableName set local_file_url = \'$localFilePath\' where message_ts = $messageTs'
    );
  }

  Future<void> updateChannelMsgReadCnt(channelUrl) async {
    Database? mydb = await db;
    if (kDebugMode) {
      print('Update channel read count ====');
    }

    await mydb?.update(
      _channelTableName, {"unread_count": "0"},
      where: "channel_url = ?",
      whereArgs: [channelUrl]
    );
  }

  Future<List<Map<String, Object?>>?> getAudioFilesWithNoLocalUrl() async {

    Database? mydb = await db;
    if (kDebugMode) {
      print('Get image files with no local file Url ====');
    }
    return await mydb?.query(
        _chatsTableName,
        where: "local_file_url IS NULL and media_type = ?",
        whereArgs: [Strings.imageMediaType],
        orderBy: "message_ts DESC"
      // _channelTableName,
      // where: "local_file_url IS NULL and media_type = \'${Strings.imageMediaType}\'",
    );
  }


}