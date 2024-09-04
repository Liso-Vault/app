import 'package:app_core/config.dart';
import 'package:app_core/config/app.model.dart';

import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:app_core/widgets/logo.widget.dart';
import 'package:app_core/widgets/version.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/core/utils/styles.dart';

import 'welcome_screen.controller.dart';

class WelcomeScreen extends StatelessWidget with ConsoleMixin {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeScreenController());

    final content = Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: Styles.containerConstraints,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSmallScreen) ...[
                const SizedBox(height: 100),
              ],
              const LogoWidget(size: 200),
              const SizedBox(height: 40),
              GradientWidget(
                gradient: LinearGradient(colors: CoreConfig().gradientColors),
                child: Text(
                  'slogan'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms)
                  .then(delay: 3000.ms),
              const SizedBox(height: 10),
              Text(
                'slogan_sub'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
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
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      label: Text('restore_vault'.tr),
                      icon: const Icon(Iconsax.import_1_outline),
                      onPressed: controller.restore,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    final bottomBar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'By proceeding, you agree to our',
          style: TextStyle(fontSize: 11),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Utils.openUrl(
                appConfig.links.terms,
              ),
              child: const Text(
                'Terms of Use',
                style: TextStyle(fontSize: 11),
              ),
            ),
            const Text(
              'and',
              style: TextStyle(fontSize: 11),
            ),
            TextButton(
              onPressed: () => Utils.openUrl(
                appConfig.links.privacy,
              ),
              child: const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        const VersionText(),
      ],
    );

    return Container(
      decoration: Get.isDarkMode
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black,
                  Color(0xFF173030),
                ],
              ),
            )
          : null,
      child: Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.transparent : null,
        bottomNavigationBar: bottomBar,
        body: controller.obx(
          (_) => content,
          onLoading: const BusyIndicator(),
        ),
      ),
    );
  }
}
