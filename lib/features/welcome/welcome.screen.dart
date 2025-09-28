import 'package:app_core/config.dart';

import 'package:app_core/globals.dart';
import 'package:app_core/pages/onboarding/laurel.widget.dart';
import 'package:app_core/pages/upgrade/review_card.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:app_core/widgets/logo.widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'welcome_screen.controller.dart';

class WelcomeScreen extends StatelessWidget with ConsoleMixin {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeScreenController());

    final topContent = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isSmallScreen) ...[
          const SizedBox(height: 100),
        ],
        const LogoWidget(size: 100),
        const SizedBox(height: 20),
        GradientWidget(
          gradient: LinearGradient(colors: CoreConfig().gradientColors),
          child: Text(
            'slogan'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2000.ms)
            .then(delay: 3000.ms),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'slogan_sub'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 40),
        const LaurelWidget(),
        const SizedBox(height: 20),
        // userReviews,
        CarouselSlider(
          items: stringReviews.map((e) => ReviewCard(review: e)).toList(),
          options: CarouselOptions(
            height: 120,
            autoPlay: true,
            enlargeCenterPage: true,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                label: Text('create_vault'.tr),
                icon: const Icon(Iconsax.box_add_outline),
                onPressed: controller.create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms)
                  .then(delay: 3000.ms),
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                label: Text('restore_vault'.tr),
                icon: const Icon(Iconsax.import_1_outline),
                onPressed: controller.restore,
              ),
            ),
          ],
        )
      ],
    );

    final versionText = Text(
      metadataApp.formattedVersion,
      style: const TextStyle(color: Colors.grey, fontSize: 10),
    );

    final footerLinks = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkThemeData.primaryColor,
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: Size.zero,
          ),
          onPressed: () => Utils.openUrl(config.links.terms),
          child: Text('terms_of_use'.tr),
        ),
        versionText,
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkThemeData.primaryColor,
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: Size.zero,
          ),
          onPressed: () => Utils.openUrl(config.links.privacy),
          child: Text('privacy_policy'.tr),
        ),
      ],
    );

    final bottomContent = Center(
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ctaButton,
              // const SizedBox(height: 10),
              footerLinks,
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    final content = [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(onboardingBGUri),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: topContent,
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: bottomContent,
      ),
    ];

    return Theme(
      data: darkThemeData,
      child: Scaffold(
        body: Stack(children: content),
      ),
    );
  }
}
