import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/firebase/analytics.service.dart';
import '../../core/firebase/config/config.service.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../feedback/feedback_screen.controller.dart';

class RateWidgetController extends GetxController with ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  // PROPERTIES
  final rating = 0.0.obs;

  // GETTERS

  // FUNCTIONS

  void skip() async {
    Get.back();
    AnalyticsService.to.logEvent('skipped-rate');
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (rating.value >= 4.0) {
      Utils.copyToClipboard(textController.text);
      UIUtils.rateAndReview();
    } else {
      Utils.contactEmail(
        subject: '${ConfigService.to.appName} Review',
        preBody: textController.text,
        rating: rating.value,
        previousRoute: Get.previousRoute,
        feedbackType: FeedbackType.feedback,
      );
    }
  }
}
