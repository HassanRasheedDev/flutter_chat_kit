class MessageCardModel {
  final String adTitle;
  final String adImageUrl;
  final String message;
  final String userName;
  final String userImageUrl;
  final String hoursAgo;
  final bool bluetick;
  final dynamic userRating;
  final dynamic unRead;
  final bool online;
  final bool fakeMessage;
  final String type;

  MessageCardModel({
    required this.adTitle,
    required this.adImageUrl,
    required this.message,
    required this.userName,
    required this.userImageUrl,
    required this.hoursAgo,
    required this.bluetick,
    required this.userRating,
    required this.unRead,
    required this.online,
    required this.fakeMessage,
    required this.type,
  });

  factory MessageCardModel.exampleMessage1() {
    return MessageCardModel(
      adTitle: 'Apple watch 42mm 2nd ',
      message: "Is This Available?",
      adImageUrl:
          'https://apple-store.pk/wp-content/uploads/2022/12/alu-spacegray-sp.jpg',
      userName: 'Saffi',
      userImageUrl:
          'https://images.unsplash.com/photo-1592334873219-42ca023e48ce?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxjb2xsZWN0aW9uLXBhZ2V8M3w3NjA4Mjc3NHx8ZW58MHx8fHx8',
      bluetick: false,
      userRating: 4.7,
      hoursAgo: "2h",
      unRead: null,
      online: false,
      fakeMessage: false,
      type: "Buying",
    );
  }

  factory MessageCardModel.exampleMessage2() {
    return MessageCardModel(
        adTitle: 'Nike Dunk SB ',
        message: "Yes it is available",
        adImageUrl:
            'https://sneakernews.com/wp-content/uploads/2014/08/nike-sb-dunk-low-prm-beijing.jpg',
        userName: 'Ahmed',
        userImageUrl:
            'https://images.unsplash.com/photo-1592334873219-42ca023e48ce?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxjb2xsZWN0aW9uLXBhZ2V8M3w3NjA4Mjc3NHx8ZW58MHx8fHx8',
        bluetick: true,
        userRating: null,
        hoursAgo: "2h",
        unRead: 1,
        online: true,
        fakeMessage: false,
        type: "Selling");
  }
  factory MessageCardModel.exampleMessage3() {
    return MessageCardModel(
        adTitle: 'Scooter',
        message: "What is the condition of the bike?",
        adImageUrl:
            'https://5.imimg.com/data5/SELLER/Default/2021/1/QE/CU/PZ/41106316/electric-passenger-rickshaw-500x500.jpeg',
        userName: 'Ahmed',
        userImageUrl:
            'https://images.unsplash.com/photo-1592334873219-42ca023e48ce?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxjb2xsZWN0aW9uLXBhZ2V8M3w3NjA4Mjc3NHx8ZW58MHx8fHx8',
        bluetick: false,
        userRating: null,
        hoursAgo: "2h",
        unRead: null,
        online: false,
        fakeMessage: true,
        type: "Selling");
  }
}
