import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/utils.dart';
import '../general/gradient.widget.dart';
import 'rate_widget.controller.dart';

class RateWidget extends StatelessWidget {
  const RateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RateWidgetController());

    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GradientWidget(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 0, 212),
                    Color.fromARGB(255, 0, 166, 255),
                  ],
                ),
                child: Text(
                  'rate_review'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Utils.isSmallScreen ? 20 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // TextButton.icon(
              //   onPressed: controller.skip,
              //   icon: const Icon(Iconsax.close_circle),
              //   label: Text('close'.tr),
              // ),
            ],
          ),
          const SizedBox(height: 15),
          TextFormField(
            autofocus: true,
            controller: controller.textController,
            validator: (data) =>
                data!.split(' ').length < 5 ? 'review_short'.tr : null,
            maxLength: 2000,
            minLines: 3,
            maxLines: 10,
            decoration: InputDecoration(
              labelText: '${'write_review_here'.tr}...',
              alignLabelWithHint: true,
              helperMaxLines: 5,
              helperText:
                  "why_love_hate".trParams({'w1': ConfigService.to.appName}),
            ),
          ),
          const SizedBox(height: 20),
          RatingBar.builder(
            initialRating: controller.rating.value,
            minRating: 0,
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            onRatingUpdate: (rating) => controller.rating.value = rating,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Get.theme.primaryColor,
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.rating.value == 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'please_give_rating'.tr,
                  style: TextStyle(
                    color: Colors.pink.shade200,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.rating.value > 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  if (controller.rating.value >= 4.0) ...[
                    ElevatedButton.icon(
                      onPressed: controller.submit,
                      icon: const Icon(Icons.star_border),
                      label: Text(
                        'Submit to ${'rate_review'.tr} ${ConfigService.to.appName}',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'spread_word'.trParams({'w1': ConfigService.to.appName}),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: controller.submit,
                      icon: const Icon(Iconsax.message_question),
                      label: Text('send_feedback'.tr),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "write_concern_helper".tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
