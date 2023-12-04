import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveController {
  static var boxNameUsers = "Users";
  static var hiveDbName = "hiveDb";

  HiveController();

  Future<void> initHive() async {
    Directory directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    await Hive.openBox(boxNameUsers);
  }

  Future<Box> getHiveBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    } else {
      await initHive();
      return Hive.box(name);
    }
  }
}
