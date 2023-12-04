import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DropDownField extends StatelessWidget {
  String hint;
  Function(String) callback;
  List<String> items;
  DropDownField(this.hint, this.items, this.callback, {super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        // Add more decoration..
      ),
      hint: Text(
        hint,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ))
          .toList(),
      onChanged: (value) {
        //Do something when selected item is changed.
        if (kDebugMode) {
          print(value);
        }
        callback.call((value.toString()));
      },
      onSaved: (value) {
        if (kDebugMode) {
          print(value);
        }
        callback.call((value.toString()));
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
