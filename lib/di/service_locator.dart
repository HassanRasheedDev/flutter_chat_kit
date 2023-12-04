import 'package:dio/dio.dart';
import 'package:flutter_chat_kit/controllers/channel_controller.dart';
import 'package:flutter_chat_kit/controllers/channel_list_controller.dart';
import 'package:flutter_chat_kit/controllers/hive_controller.dart';
import 'package:flutter_chat_kit/db_helper.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/chat_text_voice_controller.dart';
import '../controllers/filter_controller.dart';
import '../controllers/login_controller.dart';
import '../network/download_respository.dart';

final getIt = GetIt.instance;

Future<void> setup() async{


  getIt.registerSingleton(DBHelper());
  getIt.registerSingleton(HiveController());
  getIt.registerSingleton(LoginController());
  getIt.registerSingleton(ChannelListController());

  Get.put(ChatTextVoiceController());

  getIt.registerSingleton(InternetChecker());
  getIt.registerSingleton(ApplicationDirectoryProvider());

  getIt.registerSingleton(DownloadRepository());

  getIt.registerSingleton(FilterController());



}