import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/styles/colors.dart';

class AudioPlaceHolder extends StatelessWidget {
  final VoidCallback onPlayPressed;
  const AudioPlaceHolder(this.onPlayPressed,{super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0, left: 10,),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: GestureDetector(
              onTap: () async {
                //attachFileToPlayer();
                onPlayPressed();
              },
              child: const Icon(
                Icons.play_arrow,
                color: greyColor6,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 100,
        ),

        for(int i=0; i<15;i++)
          const CircleAvatar(
            radius: 2.0,
            backgroundColor: skyblueColor3,
          ),

        const SizedBox(
          width: 6,
        ),

      ],
    );
  }
}
