import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MessageCardShimmer extends StatelessWidget {
  const MessageCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Shimmer(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.black,
            Colors.white.withOpacity(0.5),
          ],
          begin: const Alignment(-1.0, -0.5),
          end: const Alignment(1.0, 0.5),
          stops: const [0.0, 0.5, 1.0],
          tileMode: TileMode.clamp,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              ShimmerSkelton(
                height: height * 0.082,
                width: height * 0.082,
              ),
              SizedBox(
                width: width * 0.023,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkelton(
                    height: height * 0.025,
                    width: width * 0.7,
                  ),
                  SizedBox(
                    height: height * 0.007,
                  ),
                  ShimmerSkelton(
                    height: height * 0.025,
                    width: width * 0.7,
                  ),
                  SizedBox(
                    height: height * 0.007,
                  ),
                  Row(
                    children: [
                      ShimmerSkelton(
                        height: height * 0.025,
                        width: height * 0.025,
                      ),
                      SizedBox(
                        width: width * 0.01,
                      ),
                      ShimmerSkelton(
                        height: height * 0.025,
                        width: width * 0.32,
                      ),
                      SizedBox(
                        width: width * 0.01,
                      ),
                      ShimmerSkelton(
                        height: height * 0.025,
                        width: width * 0.30,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

class ShimmerSkelton extends StatelessWidget {
  const ShimmerSkelton({Key? key, this.height, this.width}) : super(key: key);

  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.14),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}