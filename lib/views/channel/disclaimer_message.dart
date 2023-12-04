
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../l10n/string_en.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';

class DisclaimerMessage extends StatelessWidget {
  const DisclaimerMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: textFieldlightgreyColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/siren _icon.svg',
              width: 16,
              height: 14,
            ),
            const SizedBox(
              width: 8,
            ),
            Flexible(
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: Strings.disclamier_message,
                  style: TextStyles.txtProximaNovaNormal12(
                      appBarTextGreyColor),
                  children: <TextSpan>[
                    TextSpan(
                      text: Strings.learn_more,
                      style: TextStyles.txtProximaNovaNormal12(
                          skyblueColor2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
