enum FilterChipType {
  buying('Buying'),
  selling('Selling'),
  read('Read'),
  unread('Unread');

  const FilterChipType(this.value);
  final String value;
}

class FilterChipModel {
  final String chipTitle;
  final int chipId;
  final String chipStatus;

  FilterChipModel({
    required this.chipTitle,
    required this.chipId,
    required this.chipStatus,
  });
}

class FilterChipListModel {
  final List<FilterChipModel> filterChips;

  FilterChipListModel({required this.filterChips});

  factory FilterChipListModel.sampleData() {
    return FilterChipListModel(
      filterChips: [
        FilterChipModel(
          chipTitle: FilterChipType.buying.value,
          chipId: 2,
          chipStatus: "",
        ),
        FilterChipModel(
          chipTitle: FilterChipType.selling.value,
          chipId: 3,
          chipStatus: "",
        ),
        FilterChipModel(
          chipTitle: FilterChipType.read.value,
          chipId: 4,
          chipStatus: "",
        ),
        FilterChipModel(
          chipTitle: FilterChipType.unread.value,
          chipId: 5,
          chipStatus: "",
        ),
      ],
    );
  }
}
