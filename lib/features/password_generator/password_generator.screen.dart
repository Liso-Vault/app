import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/utils/utils.dart';
import '../general/appbar_leading.widget.dart';
import 'password_generator_screen.controller.dart';

class PasswordGeneratorScreen extends StatelessWidget with ConsoleMixin {
  const PasswordGeneratorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordGeneratorScreenController());

    const minLength = 8.0;
    const maxLength = 100.0;

    final passwordView = Obx(
      () => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.grey),
          children: controller.password.value.characters
              .toList()
              .map(
                (e) => TextSpan(
                  text: e,
                  style: TextStyle(
                    color: GetUtils.isAlphabetOnly(e)
                        ? null
                        : GetUtils.isNumericOnly(e)
                            ? themeColor
                            : Colors.teal.shade200,
                    fontSize: 30,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              'generated_password'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              child: Column(
                children: [
                  passwordView,
                  const SizedBox(height: 15),
                  const Divider(),
                  Wrap(
                    children: [
                      TextButton.icon(
                        onPressed: controller.generate,
                        label: Text('generate'.tr),
                        icon: const Icon(Iconsax.chart),
                      ),
                      TextButton.icon(
                        label: Text('copy'.tr),
                        icon: const Icon(Iconsax.copy),
                        onPressed: () => Utils.copyToClipboard(
                          controller.password.value,
                        ),
                      ),
                      if (controller.isFromDrawer) ...[
                        TextButton.icon(
                          onPressed: controller.save,
                          label: Text('save'.tr),
                          icon: const Icon(Iconsax.add_circle),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'STRENGTH: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Obx(
                  () => Text(
                    controller.strengthName.toUpperCase(),
                    style: TextStyle(
                        fontSize: 12, color: controller.strengthColor),
                  ),
                )
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Obx(
                  () => LinearProgressIndicator(
                    value: controller.strengthValue,
                    color: controller.strengthColor,
                    minHeight: 6,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text(
                  '${'length'.tr.toUpperCase()}: ',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Obx(
                  () => Text(
                    '${controller.length.toInt()}',
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          Card(
            child: Obx(
              () => Slider(
                value: controller.length.value,
                min: minLength,
                max: maxLength,
                divisions: (maxLength - minLength).toInt(),
                label: '${controller.length.value.toInt()}',
                onChanged: (value) => controller.length.value = value,
                onChangeEnd: (value) => controller.generate(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              'include'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Card(
            child: Column(
              children: [
                ObxValue(
                  (RxBool data) => SwitchListTile(
                    title: Text('letters'.tr),
                    value: data.value,
                    onChanged: (value) {
                      data.value = value;
                      controller.generate();
                    },
                  ),
                  controller.hasLetters,
                ),
                ObxValue(
                  (RxBool data) => SwitchListTile(
                    title: Text('numbers'.tr),
                    value: data.value,
                    onChanged: (value) {
                      data.value = value;
                      controller.generate();
                    },
                  ),
                  controller.hasNumbers,
                ),
                ObxValue(
                  (RxBool data) => SwitchListTile(
                    title: Text('symbols'.tr),
                    value: data.value,
                    onChanged: (value) {
                      data.value = value;
                      controller.generate();
                    },
                  ),
                  controller.hasSymbols,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Some long text note to be added in this section. Maybe with some useful links to best practices and more...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );

    final appBar = AppBar(
      title: Text('password_generator'.tr),
      leading: const AppBarLeadingButton(),
      actions: [
        if (Get.parameters['return'] != null) ...[
          IconButton(
            icon: const Icon(LineIcons.check),
            onPressed: () => Get.back(
              result: controller.password.value,
            ),
          ),
        ],
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
