import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/controllers/hive_controller.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/models/user.dart';

import '../di/service_locator.dart';
import '../main.dart';

class LoginController extends GetxController{

  Map<String, String> mapOfIds = {
    "101": "f8b3f6701e8b71c0cb6798f8ab4228413796857c",
    "102": "346e897fad8f460ded37610b4abac499c6f214ad",
    "103": "864d68d63bd1ea12aa248d80811c41d1e5dddd11",
    "104": "5e8b104d4b8abb1250d271029164b61ffe658629"
  };

  final _hiveController = getIt<HiveController>();

  RxBool isLoading = false.obs;

  Future<User> login(String userId, String nickname) async{

    if (userId == '') {
      throw Error();
    }

    isLoading.value = true;
    try {
      // initialize with app id
      //sendbird.setLogLevel(LogLevel.verbose);
      // connect to sendbird server
      final user = await sendbird.connect(userId, accessToken: mapOfIds[userId] ?? "");
      final name = nickname == '' ? user.userId : nickname;
      await sendbird.updateCurrentUserInfo(nickname: name);


      // saving user to hive
      saveUser(user);


      isLoading.value = false;
      return user;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('login_view.dart: _signInButton: ERROR: $e');
      }
      rethrow;
    }

  }


  void showLoginFailAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: RichText(
            textAlign: TextAlign.left,
            softWrap: true,
            text: TextSpan(
              text: 'Login Failed:  ',
              style: Theme.of(context).textTheme.titleMedium,
              children: [
                TextSpan(
                  text: 'Check connectivity and App Id',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveUser(User user) async {
    Box userBox = await _hiveController.getHiveBox(HiveController.boxNameUsers);
    // var tempUser = User(userId: user.userId, nickname: user.nickname,
    //     sessionToken: user.sessionToken, profileUrl: user.profileUrl, lastSeenAt: user.lastSeenAt);
    await userBox.put("profile", user.toJson());
  }

}