
import 'dart:async';
import 'dart:isolate';

@pragma('vm:entry-point')
void downloadImages(String command) {
  Timer.periodic(const Duration(seconds:100),(timer)=>print("hello"));

}
