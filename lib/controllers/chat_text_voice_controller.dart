import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/string_en.dart';
import 'channel_controller.dart';


class ChatTextVoiceController extends GetxController  {

  Rx<File> _filePath = File("").obs;
  TextEditingController textEditingController = TextEditingController();
  RxBool isTextEmpty = true.obs;

  late final RecorderController recorderController;

  Rx<Duration> _voiceMsgDuration = const Duration(seconds: 0).obs;

  Rx<Duration> get elapsedDuration => _voiceMsgDuration;


  String? path;
  String? musicFile;
  RxBool isRecording = false.obs;
  RxBool isPaused = false.obs;
  RxBool isRecordingCompleted = false.obs;
  RxBool isLoading = true.obs;

  late Directory appDirectory;


  @override
  void onInit() {
    super.onInit();
    textEditingController.addListener(_onTextChanged);
    getDir();
    initialiseControllers();



  }
  void getDir() async {
    appDirectory = await getApplicationCacheDirectory();
    path = "${appDirectory.path}/recording.m4a";
    isLoading.value = false;
  }

  void initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    recorderController.addListener(() {
      _voiceMsgDuration.value = recorderController.elapsedDuration;
    });

  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      musicFile = result.files.single.path;
    } else {
      debugPrint("File not picked");
    }
    update(); // To trigger UI update
  }

  void startOrStopRecording(ChannelController channelController) async {
    try {
      if (isRecording.value) {
        recorderController.reset();
        final path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted.value = true;
          isPaused.value = false;
          saveToAppCache(File(path), "AudioMessage",channelController);
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path).lengthSync()}");
        }
      } else {
        isPaused.value = false;
        await recorderController.record(path: path!);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isRecording.value = !isRecording.value;
    }
    update(); // To trigger UI update
  }

  void refreshWave() {
    if (isRecording.value) recorderController.refresh();
  }

  void stopRecording() {
    if (isRecording.value) recorderController.stop();
  }

  void pause() {
    recorderController.pause();
    isPaused.value = true;
  }





  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }
  void _onTextChanged() {
    isTextEmpty.value = textEditingController.text.isEmpty;
  }


  String formatDuration(Duration duration) {
    int seconds = duration.inSeconds;
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }




  Future<void> openGalleryCamera(String type, ChannelController channelController) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (type=="Gallery")? await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 25) : await _picker.pickImage(source: ImageSource.camera, imageQuality: 25);



    if (image != null) {
      _filePath.value = File(image.path);


      await saveToAppCache(_filePath.value, "Image", channelController);

    } else {
      // User canceled the picker
      print("Image selection canceled");

    }
  }
  Future<void> openFileManager(ChannelController channelController) async {
    try {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles( type: FileType.custom,
        allowedExtensions: ['mp3'],);

      if (result != null) {
        final PlatformFile file = result.files.first;
        _filePath.value = File(file.path ?? "");

        await saveToAppCache(_filePath.value, "File",channelController);
      } else {
        // User canceled the file picker
        print("File selection canceled");
      }
    } catch (e) {
      print("Error opening file manager: $e");
    }
  }
  Future<void> saveToAppCache(File messageFile, String type, ChannelController channelController) async {
    try {
      // Get the app's cache directory
      final Directory appCacheDir = await getTemporaryDirectory();
      // Create a unique file name for the image
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = type == "Image" ? '${appCacheDir.path}/$fileName.jpg' :type == "AudioMessage"? '${appCacheDir.path}/$fileName.${Strings.audioExtensionM4a}' :'${appCacheDir.path}/$fileName.${Strings.audioExtensionMp3}';

      // Copy the selected image to the app's cache directory
      await messageFile.copy(filePath);
      channelController?.onSendFileMessage(File(filePath));

      /*chatController.addMessage(Message(isMe: true,
        read: true,
        time: DateTime.now(),
        messageType: 'FILE',
        filePath : filePath ,
        userImageUrl: 'https://images.unsplash.com/photo-1592334873219-42ca023e48ce?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxjb2xsZWN0aW9uLXBhZ2V8M3w3NjA4Mjc3NHx8ZW58MHx8fHx8',
      ));*/
      print("Image saved to cache: $filePath");
    } catch (e) {
      print("Error saving image to cache: $e");
    }
  }

}
