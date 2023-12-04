import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/filter_model.dart';
import '../models/message_card.dart';

class FilterController extends GetxController {
  RxString selectedFilter = "".obs;
  RxBool filterSelected = false.obs;
  RxBool cardShimmer = false.obs;

  List<MessageCardModel> allMessages = [
    MessageCardModel.exampleMessage2(),
    MessageCardModel.exampleMessage1(),
    MessageCardModel.exampleMessage3(),
  ];

  RxList<MessageCardModel> currentFilteredMessages = <MessageCardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentFilteredMessages.assignAll(allMessages);
    currentFilteredMessages.refresh();
  }

  void filterSelect(bool value) {
    filterSelected.value = value;
    if (filterSelected.value == false) {
      currentFilteredMessages.assignAll(allMessages);
    }
  }

  void showShimmer() {
    cardShimmer.value = true;
    if (kDebugMode) {
      print("called for true");
    }
    Future.delayed(const Duration(seconds: 1), () {
      cardShimmer.value = false;
      if (kDebugMode) {
        print("called for false");
      }
    });
  }
  void filterMessages(String query) {
    // Reset the filtered messages list
    currentFilteredMessages.clear();

    // If the query is empty, show all messages
    if (query.isEmpty) {
      currentFilteredMessages.addAll(allMessages);
    } else {
      // Filter messages based on the search query
      currentFilteredMessages.addAll(allMessages.where((message) =>
      message.adTitle.toLowerCase().contains(query.toLowerCase()) ||
          message.userName.toLowerCase().contains(query.toLowerCase()) ||
          message.message.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void updateSelectedFilter(String chipTitle) {
    selectedFilter.value = chipTitle;

    if (chipTitle == FilterChipType.buying.value) {
      currentFilteredMessages.assignAll(allMessages
          .where((element) => element.type == FilterChipType.buying.value)
          .toList());
    } else if (chipTitle == FilterChipType.selling.value) {
      currentFilteredMessages.assignAll(allMessages
          .where((element) => element.type == FilterChipType.selling.value)
          .toList());
    } else if (chipTitle == FilterChipType.read.value) {
      currentFilteredMessages.assignAll(
          allMessages.where((element) => element.unRead == null).toList());
    } else if (chipTitle == FilterChipType.unread.value) {
      currentFilteredMessages.assignAll(
          allMessages.where((element) => element.unRead != null).toList());
    }



  }
}
