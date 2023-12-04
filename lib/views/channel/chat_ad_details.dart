import 'package:flutter/material.dart';

import '../../../l10n/string_en.dart';
import '../../../utils/img_constants.dart';
import '../../models/ad_posting_model.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';

class ChatAdDetails extends StatelessWidget {
  ChatAdDetails({super.key});

  @override
  Widget build(BuildContext context) {

    AdpostingModel? adPosting = AdpostingModel.addposting2();

    return Container(
      height: 100,
      color: lightblueColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: FadeInImage.assetNetwork(
                placeholder: ImageConstant.loadingImage,
                image: adPosting.adImageUrl,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    ImageConstant.loadingImage,
                    width: 60,
                    height: 60,
                  );
                },
                fit: BoxFit.fill,
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          adPosting.adTitle,
                          style: TextStyles.txtProximaNovaNormal16(
                            greyColor4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      adPosting.status == "Live"
                          ? Container(
                              width: 46,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(44),
                                color: greenColor,
                              ),
                              child: Center(
                                child: Text(
                                  adPosting.status,
                                  style: TextStyles.txtProximaNovaBold13(
                                      whiteColor),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    adPosting.price,
                    style: TextStyles.txtProximaNovaExtraBold20(
                      greyColor4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            adPosting.location,
                            style: TextStyles.txtProximaNovaNormal14(
                              greyColor4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          Strings.dot_separator,
                          style: TextStyles.txtProximaNovaNormal14(
                            greyColor4,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            adPosting.date,
                            style: TextStyles.txtProximaNovaNormal14(
                              greyColor4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
