
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/di/service_locator.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../models/filter_model.dart';
import '../../controllers/filter_controller.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../utils/icon_constants.dart';

class FilterChipWidget extends StatefulWidget {
  FilterChipWidget(
      {super.key,
      required this.filterChipList,
      required this.onFilterSelected});
  final FilterChipListModel filterChipList;
  final void Function(FilterChipModel) onFilterSelected;

  @override
  State<FilterChipWidget> createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  int _selectedIndex = -1;
  FilterController filterController = getIt.get<FilterController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.filterChipList.filterChips.length,
              itemBuilder: (context, index) {
                FilterChipModel filterChip =
                    widget.filterChipList.filterChips[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = _selectedIndex == index ? -1 : index;
                        if (_selectedIndex == index) {
                          widget.onFilterSelected(filterChip);
                          filterController.filterSelect(true);
                          filterController.showShimmer();
                        } else if (_selectedIndex == -1) {
                          filterController.filterSelect(false);
                        }
                      });
                    },
                    child: Container(
                      width: _selectedIndex == index ? 85 : 61,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedIndex == index
                            ? blackColor
                            : whiteColor,
                        border: Border.all(
                          color: _selectedIndex == index
                              ? blackColor
                              : filterChipBorderGreyColor,
                          width: 1.0,
                        ),
                      ),
                      child: _selectedIndex == index
                          ? Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      filterChip.chipTitle,
                                      style: _selectedIndex == index
                                          ? TextStyles.txtProximaNovaNormal13(
                                              whiteColor)
                                          : TextStyles.txtProximaNovaNormal13(
                                              greyColor,
                                            ), // Change text color based on selection
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    IconConstants.crossIcon,
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                filterChip.chipTitle,
                                style: _selectedIndex == index
                                    ? TextStyles.txtProximaNovaNormal13(
                                        whiteColor)
                                    : TextStyles.txtProximaNovaNormal13(
                                        greyColor,
                                      ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        /*SvgPicture.asset(
          'assets/icons/filter_icon.svg',
          width: 18,
          height: 12,
        ),
     */ ],
    );
  }
}
