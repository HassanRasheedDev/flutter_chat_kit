import 'package:flutter/material.dart';

import '../../styles/colors.dart';
import '../../styles/text_styles.dart';

class SearchBarWidget extends StatelessWidget {
  SearchBarWidget({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onTextChanged,
  });

  final String hintText;
  final TextEditingController controller;
  final Function(String) onTextChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onTextChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search,
          color: lightgreyColor,
        ),
        filled: true,
        fillColor: textFieldlightgreyColor,
        hintStyle: TextStyles.txtProximaNovaNormal14(
            hintTextgreyColor.withOpacity(0.54)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
