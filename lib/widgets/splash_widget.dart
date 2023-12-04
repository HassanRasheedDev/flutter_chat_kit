import 'package:flutter/material.dart';

import '../main.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Container(
          height: 100,
          padding: const EdgeInsets.only(top: 40),
          child: Image(image: assetImage, height: 36, width: 36,),
        ),
      ),
    );
  }
}
