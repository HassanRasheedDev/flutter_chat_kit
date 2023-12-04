import 'package:sendbird_sdk/constant/enums.dart';

Map<MessageSendingStatus, String> MessageSendingStatusEnumMap = {
  MessageSendingStatus.none: 'none',
  MessageSendingStatus.pending: 'pending',
  MessageSendingStatus.failed: 'failed',
  MessageSendingStatus.succeeded: 'succeeded',
  MessageSendingStatus.canceled: 'canceled',
};

Map<ChannelType, String> ChannelTypeEnumMap = {
  ChannelType.group: 'group',
  ChannelType.open: 'open',
};