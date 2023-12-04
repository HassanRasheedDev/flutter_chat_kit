import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apns_x/flutter_apns/apns.dart';
import 'package:flutter_apns_x/flutter_apns/flutter_apns_x.dart';
import 'package:flutter_apns_x/flutter_apns/src/connector.dart';
import 'package:flutter_chat_kit/controllers/hive_controller.dart';
import 'package:flutter_chat_kit/controllers/login_controller.dart';
import 'package:flutter_chat_kit/models/channel_model.dart';
import 'package:flutter_chat_kit/styles/light_theme.dart';
import 'package:flutter_chat_kit/utils/extensions.dart';
import 'package:flutter_chat_kit/utils/notification_service.dart';
import 'package:flutter_chat_kit/views/channel/channel_screen.dart';
import 'package:flutter_chat_kit/views/channel_list/channel_list_screen.dart';
import 'package:flutter_chat_kit/views/login/login_screen.dart';
import 'package:flutter_chat_kit/widgets/splash_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/models/user.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';

import 'di/service_locator.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 10;
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();
  setup();
  userProfile = await getUserFromHive();

  runApp(const MyApp());
}


Future<Map<String, dynamic>> getUserFromHive() async {
  final hiveController = getIt<HiveController>();
  Box userBox =  await hiveController.getHiveBox(HiveController.boxNameUsers);
  var hiveMap = await userBox.get("profile") as Map<dynamic, dynamic>?;
  Map<String, dynamic>? map = {};

  (hiveMap)?.forEach((key, value) {
    if(key is String) {
      map.putIfAbsent(key, () => value);
    }
  });
  return map;
}

User? getSendBirdLocalUser(){
  if(sendbird.currentUser == null && userProfile?.isNotEmpty == true){
    return User.fromJson(userProfile!);
  }else{
    return sendbird.currentUser;
  }
}


Map<String,dynamic>? userProfile;
final sendbird = SendbirdSdk(appId: '68957A19-A398-44F8-AF6C-729692804B45');
var isUserConnectedOnline = false.obs;
var isInternetConnected = false.obs;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//* If web Do not create push connector
final connector = kIsWeb ? null : createPushConnector();
final appState = AppState();
late AssetImage assetImage;

class AppState with ChangeNotifier {
  bool didRegisterToken = false;
  String? token;
  String? destChannelUrl;

  void setDestination(String? channelUrl) {
    destChannelUrl = channelUrl;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  //* If web do not create push Connector

  final PushConnector? connector = kIsWeb ? null : createPushConnector();

  Future<void> _register() async {
    //if it is not web: connector will exist
    final connector = this.connector!;
    connector.configure(
      onLaunch: (data) async {
        //launch
        if (kDebugMode) {
          print(data);
          print('onLaunch: $data');
        }
        final rawData = data.data;
        appState.setDestination(rawData['sendbird']['channel']['channel_url']);

      },
      onResume: (data) async {
        //called when user tap on push notification
        if (kDebugMode) {
          print('onResume');
          print(data);
        }
        final rawData = data.data;
        appState.setDestination(rawData['sendbird']['channel']['channel_url']);
      },
      onMessage: (data) async {
        //terminated? background
        if (kDebugMode) {
          print('onMessage: $data');
        }
      },
      onBackgroundMessage: handleBackgroundMessage,
    );
    connector.token.addListener(() {
      if (kDebugMode) {
        print('Token ${connector.token.value}');
      }
      appState.token = connector.token.value;
    });
    connector.requestNotificationPermissions();
  }

  @override
  void initState() {
    //* If web do not register
    if (kIsWeb == false) {
      _register();
    }
    assetImage = const AssetImage('assets/logoSendbird.png');

    registerInternetConnectionChecker();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    preCacheImages(context);
    super.didChangeDependencies();
  }

  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    
    return MaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: "/",
      onGenerateRoute: (settings) {
        var routes = <String, WidgetBuilder>{
          '/': (context) => FutureBuilder<dynamic>(
              future: getUserProfile(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                // return getRespectiveWidget(snapshot);
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const SplashWidget();
                }else{
                  if(snapshot.data!= null){
                    return const ChannelListScreen();
                  }else{
                    return const LoginScreen();
                  }
                }
              }
          ),
          '/channel_list': (context) => const ChannelListScreen(),
          '/channel': (context) =>
              ChannelScreen(channel: settings.arguments as MainChannel),
        };
        WidgetBuilder builder = routes[settings.name]!;
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => builder(ctx),
        );
      },
    );
  }

  Future<dynamic> getUserProfile() async {
    final loginController = getIt<LoginController>();
    if(userProfile?.isNotEmpty == true){
      return userProfile;
    }else{
      return await loginController.login(userProfile?["user_id"], userProfile?["nickname"]);
    }
  }

  Widget getRespectiveWidget(AsyncSnapshot<User> snapshot) {
    if(snapshot.connectionState == ConnectionState.waiting){
      return const Scaffold();
    }else{
      if(snapshot.data!= null){
        return const ChannelListScreen();
      }else{
        return const LoginScreen();
      }
    }
  }

  void registerInternetConnectionChecker() {
    final internetChecker = getIt<InternetChecker>();
    // Listen for changes in internet connection
    internetChecker.onInternetConnectionChange.listen((bool isConnected) async {

      if (kDebugMode) {
        print('Internet connection status changed. Is connected: $isConnected');
      }

      if(isConnected){
        // Connecting user....
        isInternetConnected.value = true;
        await makeConnectionRequest();
      }else{
        isInternetConnected.value = false;
        isUserConnectedOnline.value = false;
      }
    });
  }

  void preCacheImages(BuildContext context) {
   precacheImage(assetImage, context);
  }

}




Future<void> makeConnectionRequest() async {
  final hiveController = getIt<HiveController>();
  final loginController = getIt<LoginController>();
  if (kDebugMode) {
    print('Connecting user with sendbird');
  }
  Box userBox =  await hiveController.getHiveBox(HiveController.boxNameUsers);
  final userProfile = await userBox.get("profile");
  if(userProfile != null){
    var user = await loginController.login(userProfile["user_id"], userProfile["nickname"]);
    isUserConnectedOnline.value = true;
    if (kDebugMode) {
      print('User connected: ${user.userId} , Connection status  ${user.connectionStatus.name}');
    }
  }
}


Future<dynamic> handleBackgroundMessage(RemoteMessage data) async {
  if (kDebugMode) {
    print('onBackground $data');
  } // android only for firebase_messaging v7
  NotificationService.showNotification(
    'Sendbird Example',
    data.data['data']['message'],
    payload: data.data['data']['sendbird'],
  );
}
