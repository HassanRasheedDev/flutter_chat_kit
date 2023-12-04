import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/styles/colors.dart';

class TextStyles{
  static const fontFamily = "Roboto";
  static const appMainProximaNovaFont = "Proxima Nova";


  static const sendbirdCaption1OnDark1 = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontFamily: fontFamily,
      fontStyle: FontStyle.normal,
      fontSize: 12.0);

  static const sendbirdCaption4OnLight3 = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w400,
      fontFamily: fontFamily,
      fontStyle: FontStyle.normal,
      fontSize: 11.0);

  static const sendbirdCaption1OnLight2 = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w700,
      fontFamily: fontFamily,
      fontStyle: FontStyle.normal,
      fontSize: 12.0);

  static const sendbirdButtonPrimary300 = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w700,
      fontFamily: fontFamily,
      fontStyle: FontStyle.normal,
      fontSize: 14.0);

  static const sendbirdButtonOnDark1 = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.w700,
      fontFamily: fontFamily,
      fontStyle: FontStyle.normal,
      fontSize: 14.0);

  static TextStyle txtProximaNovaBold16(Color color) {
    return TextStyle(
      color: color,
      fontSize: 16,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w600,
    );
  }
  static TextStyle txtProximaNovaNormal14(color) {
    return TextStyle(
      color: color,
      fontSize: 14,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle txtProximaNovaNormal13(color) {
    return TextStyle(
      color: color,
      fontSize: 13,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle txtProximaNovaExtraBold14(color) {
    return TextStyle(
      color: color,
      fontSize: 14,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle txtProximaNovaBold12(Color color) {
    return TextStyle(
      color: color,
      fontSize: 12,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle txtProximaNovaNormal16(Color color) {
    return TextStyle(
      color: color,
      fontSize: 16,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle txtProximaNovaNormal12(Color color) {
    return TextStyle(
      color: color,
      fontSize: 12,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle txtProximaNovaBold13(color) {
    return TextStyle(
      color: color,
      fontSize: 13,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle txtProximaNovaExtraBold20(Color color) {
    return TextStyle(
      color: color,
      fontSize: 20,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle txtRobotoNovaNormal12(Color color) {
    return TextStyle(
      color: color,
      fontSize: 12,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle txtProximaNovaBold14LineHeight20(color) {
    return TextStyle(
      color: color,
      fontSize: 14,
      fontFamily: appMainProximaNovaFont,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
  }



}