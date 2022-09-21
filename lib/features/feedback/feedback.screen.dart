import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/utils/globals.dart';

import '../general/appbar_leading.widget.dart';
import 'feedback_screen.controller.dart';

class FeedbackScreen extends StatelessWidget with ConsoleMixin {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackScreenController());

    final content = Form(
      key: controller.formKey,
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: controller.feedbackType,
                onChanged: (value) => controller.feedbackType = value!,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Feedback',
                    child: Text('Feedback'),
                  ),
                  DropdownMenuItem(
                    value: 'Suggestion',
                    child: Text('Suggestion'),
                  ),
                  DropdownMenuItem(
                    value: 'Issue',
                    child: Text('Issue'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                autofocus: true,
                controller: controller.textController,
                validator: (data) => data!.split(' ').length < 5
                    ? 'Your feedback is too short'
                    : null,
                maxLength: 2000,
                minLines: 3,
                maxLines: 10,
                decoration: const InputDecoration(
                    labelText: 'Write your concern here...',
                    alignLabelWithHint: true,
                    helperMaxLines: 5,
                    helperText:
                        "Please don't hesitate to send us your feedback and we'll be happy to chat with you. Expect a reply within 24-48 hours."),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: controller.rating.value,
                minRating: 0,
                direction: Axis.horizontal,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (rating) => controller.rating.value = rating,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: kAppColor,
                ),
              ),
              Obx(
                () => Visibility(
                  visible: controller.rating.value == 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Please give us your star rating',
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
                  visible: controller.showRateButton,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: controller.review,
                        icon: const Icon(Icons.star_border),
                        label: Text(
                          'Rate & Review ${ConfigService.to.appName} on ${GetPlatform.isIOS || GetPlatform.isMacOS ? 'the App Store' : 'Google Play'}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Help spread the word about why people should consider using ${ConfigService.to.appName} as their password manager.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );

    final appBar = AppBar(
      title: Text('Contact ${ConfigService.to.appName}'),
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton.icon(
          label: const Text('Send'),
          icon: const Icon(Iconsax.send_2),
          onPressed: controller.send,
        ),
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
