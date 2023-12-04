import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/controllers/channel_list_controller.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:flutter_chat_kit/views/channel_list/channel_list_item.dart';
import 'package:flutter_chat_kit/widgets/card_shimmer.dart';
import 'package:flutter_chat_kit/widgets/splash_widget.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/utils/extensions.dart';

import '../../controllers/filter_controller.dart';
import '../../di/service_locator.dart';
import '../../l10n/string_en.dart';
import '../../models/filter_model.dart';
import '../../styles/text_styles.dart';
import 'filter_chip.dart';
import 'search_bar.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({super.key});

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  final controller = getIt<ChannelListController>();
  TextEditingController searchController = TextEditingController();

  FilterController filterController = getIt.get<FilterController>();

  FilterChipListModel filterChipList = FilterChipListModel.sampleData();

  @override
  void initState() {
    super.initState();
    controller.loadChannelList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.01,
        title: InkWell(
          child: Text(
            "Chat",
            style: TextStyles.txtProximaNovaBold16(appBarTextGreyColor),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SearchBarWidget(
              hintText: Strings.search,
              controller: searchController,
              onTextChanged: (query) {
                controller.filterMessages(query.trim());
              },
            ),
          ),

          const Divider(
              thickness: 2,
              color: textFieldlightgreyColor),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: FilterChipWidget(
              onFilterSelected: (FilterChipModel selectedFilter) {
                filterController.updateSelectedFilter(selectedFilter.chipTitle);
              },
              filterChipList: filterChipList,
            ),
          ),

          const Divider(
              thickness: 2,
              color: textFieldlightgreyColor),

          Obx(() => controller.isLoading.value
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return const MessageCardShimmer();
                  },
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.loadChannelList(reload: true);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.itemCount,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) {
                      return const Divider(
                          thickness: 2,
                          color: textFieldlightgreyColor);
                    },
                    itemBuilder: (context, index) {
                      final channel = controller.groupChannels[index];
                      return InkWell(
                        child: ChannelListItem(channel),
                        onTap: () {
                          navigateToChannelScreen(channel);
                        },
                      );
                    },
                  ),
                )),

          const Divider(
              thickness: 2,
              color: textFieldlightgreyColor),
        ],
      ),
    );
  }

  Future<void> navigateToChannelScreen(channel) async {
    await Navigator.pushNamed(
      context,
      '/channel',
      arguments: channel,
    ).then((value) {
      controller.loadChannel(channel);
    });
  }
}

/*
 */
