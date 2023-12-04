class AdpostingModel {
  final String adTitle;
  final String adImageUrl;
  final String date;
  final String status;
  final String location;
  final String price;

  AdpostingModel(
      {required this.adTitle,
      required this.adImageUrl,
      required this.date,
      required this.status,
      required this.location,
      required this.price});

  factory AdpostingModel.addposting1() {
    return AdpostingModel(
        adTitle: 'Apple watch 42mm 2nd',
        adImageUrl:
            'https://apple-store.pk/wp-content/uploads/2022/12/alu-spacegray-sp.jpg',
        date: '2023-11-24',
        status: 'Live',
        location: 'Deira, Dubai',
        price: 'AED 1000');
  }

  factory AdpostingModel.addposting2() {
    return AdpostingModel(
        adTitle: 'Nike Dunk SB',
        adImageUrl:
            'https://sneakernews.com/wp-content/uploads/2014/08/nike-sb-dunk-low-prm-beijing.jpg',
        date: '2023-11-25',
        status: 'Live',
        location: 'Deira, Dubai',
        price: 'AED 1000');
  }

  factory AdpostingModel.addposting3() {
    return AdpostingModel(
        adTitle: 'Scooter',
        adImageUrl:
            'https://5.imimg.com/data5/SELLER/Default/2021/1/QE/CU/PZ/41106316/electric-passenger-rickshaw-500x500.jpeg',
        date: '2023-11-26',
        status: 'Pending',
        location: 'Deira, Dubai',
        price: 'AED 1000');
  }
}
