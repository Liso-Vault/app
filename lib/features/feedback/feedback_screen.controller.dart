import 'package:app_review/app_review.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';

class FeedbackScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  String feedbackType = 'Feedback';
  final rating = 0.0.obs;

  // PROPERTIES

  // GETTERS

  bool get showRateButton =>
      rating.value >= 4.0 &&
      (GetPlatform.isAndroid ||
          GetPlatform.isIOS ||
          (GetPlatform.isMacOS && isMacAppStore));

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
      subject: '${ConfigService.to.appName} $feedbackType',
      preBody: textController.text,
      rating: rating.value,
      previousRoute: Get.previousRoute,
    );
  }

  void review() async {
    Utils.copyToClipboard(textController.text);

    final store = ConfigService.to.general.app.links.store;
    final available = await AppReview.isRequestReviewAvailable;
    console.info('review available: $available');

    if (GetPlatform.isAndroid) {
      if (available) {
        final result = await AppReview.openAndroidReview();
        console.info('review result: $result');
      } else {
        Utils.openUrl(store.google);
      }
    } else if (GetPlatform.isIOS) {
      if (available) {
        final result = await AppReview.openIosReview();
        console.info('review result: $result');
      } else {
        Utils.openUrl(store.apple);
      }
    } else if (GetPlatform.isMacOS) {
      Utils.openUrl(store.apple);
    }
  }
}
