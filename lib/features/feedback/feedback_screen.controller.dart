import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';

enum FeedbackType {
  feedback,
  suggestion,
  issue,
}

class FeedbackScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  var feedbackType = FeedbackType.feedback;
  final rating = 0.0.obs;

  // PROPERTIES

  // GETTERS

  bool get showRateButton => rating.value >= 4.0 && isRateReviewSupported;

  // INIT

  // FUNCTIONS

  void send() async {
    if (!formKey.currentState!.validate()) return;

    if (rating.value == 0.0) {
      return UIUtils.showSimpleDialog(
        'Give A Rating',
        'Please give us your rating from 1 - 5 stars.',
      );
    }

    Utils.contactEmail(
      subject:
          '${ConfigService.to.appName} ${feedbackType.toString().replaceAll('FeedbackType.', '').capitalizeFirst}',
      preBody: textController.text,
      rating: rating.value,
      previousRoute: Get.previousRoute,
      feedbackType: feedbackType,
    );
  }

  void review() async {
    Utils.copyToClipboard(textController.text);
    UIUtils.rateAndReview();
  }
}
