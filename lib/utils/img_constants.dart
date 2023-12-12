import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';

class ImageConstant {

  static var placeHolderPaths = [
    "assets/placeholders/blur_image1.jpg",
    "assets/placeholders/blur_image2.jpg",
    "assets/placeholders/blur_image3.jpg",
    "assets/placeholders/blur_image4.jpg",
    "assets/placeholders/blur_image5.jpg",
    "assets/placeholders/blur_image6.jpg",
    "assets/placeholders/blur_image7.jpg",
    "assets/placeholders/blur_image8.jpg",
    "assets/placeholders/blur_image9.jpg",
    "assets/placeholders/blur_image10.jpg",
    "assets/placeholders/blur_image11.jpg",
    "assets/placeholders/blur_image12.jpg",
    "assets/placeholders/blur_image13.jpg",
    "assets/placeholders/blur_image14.jpg",
    "assets/placeholders/blur_image15.jpg",
    "assets/placeholders/blur_image16.jpg",
    "assets/placeholders/blur_image17.jpg",
    "assets/placeholders/blur_image18.jpg",
    "assets/placeholders/blur_image19.jpg",
    "assets/placeholders/blur_image20.jpg",
    "assets/placeholders/blur_image21.jpg",
    "assets/placeholders/blur_image22.jpg",
  ];
  static var preCachedBlurImages = [];

  static Image get precachedPlaceHolder => preCachedBlurImages[Random().nextInt(placeHolderPaths.length - 1)];

  static String loadingImage = "assets/images/loading.png";
  static String userImage = "assets/images/user_image.png";

  static void precachePlaceHolders(BuildContext context) {

    for(int i=0; i< placeHolderPaths.length; i++){
      Image image = Image.asset(
          height: 160,
          width: 240,
          fit: BoxFit.cover,
          placeHolderPaths[i]
      );
      precacheImage(image.image, context);
      preCachedBlurImages.add(image);
    }
  }
}
