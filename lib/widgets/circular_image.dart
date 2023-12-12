import 'package:flutter/widgets.dart';

class CircularImageContainer extends StatelessWidget {
  CircularImageContainer({super.key,
     required this.height,required this.width,required this.imageUrl,required this.placeHolder,required this.radius});
  String placeHolder;
  String imageUrl;
  double height;
  double width;
  double radius;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(64),
      child: FadeInImage.assetNetwork(
        placeholder: placeHolder,
        image: imageUrl,
        fit: BoxFit.cover,
        imageErrorBuilder: (context, error, stackTrace) {
          return Image.asset(
           placeHolder,
            width: width,
            height: height,
          );
        },
        width: width,
        height: height,
      ),
    );
  }
}

