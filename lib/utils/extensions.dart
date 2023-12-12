import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

extension DateUtil on int {
  String readableTimestamp() {
    final formatter = DateFormat('HH:mm a');
    final date = DateTime.fromMillisecondsSinceEpoch(this);
    return formatter.format(date);
  }

  String readableLastSeen() {
    final date = DateTime.fromMillisecondsSinceEpoch(this);
    final now = DateTime.now();
    const lastSeen = 'Last seen';

    if (now.year != date.year || now.month != date.month) {
      final formatter = DateFormat('MMM dd, yyyy');
      return '$lastSeen on ${formatter.format(date)}';
    } else if (now.day != date.day) {
      final diff = now.day - date.day;
      return '$lastSeen $diff day${(diff > 1) ? 's' : ''} ago';
    } else if (now.hour != date.hour) {
      final diff = now.hour - date.hour;
      return '$lastSeen $diff hour${(diff > 1) ? 's' : ''} ago';
    } else if (now.minute != date.minute) {
      final diff = now.minute - date.minute;
      return '$lastSeen $diff minute${(diff > 1) ? 's' : ''} ago';
    } else if (now.second != date.second) {
      final diff = now.second - date.second;
      return '$lastSeen $diff second${(diff > 1) ? 's' : ''} ago';
    }
    return '';
  }
}


extension DirectoryUtil on String {
  bool isDirectoryPath(userId){
    return contains(userId) ? true : false;
  }
}



extension InternetConnection on ConnectivityResult {
  bool get isConnected => this == ConnectivityResult.mobile || this == ConnectivityResult.wifi;
}

class InternetChecker {
  final Connectivity _connectivity = Connectivity();

  Future<bool> checkInternetConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result.isConnected;
  }

  Stream<bool> get onInternetConnectionChange =>
      _connectivity.onConnectivityChanged.map((ConnectivityResult result) => result.isConnected);
}

class ApplicationDirectoryProvider{
  Directory? _applicationDirectoryProvider;
  Map<String, String>  localFiles = {};
  ApplicationDirectoryProvider() {
    getDirectory();
  }

  get instance => this;
  Future<void> getDirectory() async {
    _applicationDirectoryProvider = await getApplicationDocumentsDirectory();
    getFilesAvailable();
  }

  void getFilesAvailable() {
    _applicationDirectoryProvider?.listSync().forEach((filePath) {
      if(filePath.path.isBlank == false && (filePath.path.endsWith(".jpg"))){
        var arr = filePath.path.split("/");
        localFiles.putIfAbsent(arr.last, () => filePath.path);
      }
    });
  }

  Map<String, String> getLocalFiles() => localFiles;
  getDirectoryPath() => _applicationDirectoryProvider;



}
