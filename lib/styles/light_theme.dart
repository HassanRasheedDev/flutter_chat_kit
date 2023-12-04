import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:flutter_chat_kit/styles/text_styles.dart';

const appMainProximaNovaFont = "Proxima Nova";

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,

  primaryColor: redColor,
  fontFamily: appMainProximaNovaFont,
  scaffoldBackgroundColor: scaffoldBackgroundColorLight,
  appBarTheme: AppBarTheme(
      color: whiteColor,
      centerTitle: true,
      titleTextStyle: TextStyles.txtProximaNovaBold16(greyColor),
      elevation: 1),
  inputDecorationTheme: const InputDecorationTheme(
    prefixIconColor: lightgreyColor,
    contentPadding: EdgeInsets.all(8.0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              )))),

  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 96, fontWeight: FontWeight.w300, color: Colors.black),
    displayMedium: TextStyle(
        fontSize: 60, fontWeight: FontWeight.w400, color: Colors.black),
    displaySmall: TextStyle(
        fontSize: 48, fontWeight: FontWeight.w400, color: Colors.black),
    headlineMedium: TextStyle(
        fontSize: 34, fontWeight: FontWeight.w400, color: Colors.black),
    headlineSmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w400, color: Colors.black),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
    bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
    bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
  ),

  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  ),

);