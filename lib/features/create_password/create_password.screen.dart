import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';

import 'create_password_screen.controller.dart';

class CreatePasswordScreen extends GetView<CreatePasswordScreenController>
    with ConsoleMixin {
  const CreatePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LineIcons.alternateShield, size: 100),
          const SizedBox(height: 20),
          const Text(
            'Vault Password',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 15),
          const Text(
            'This will be the password to unlock the vault',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: controller.obscure(),
              textInputAction: TextInputAction.next,
              validator: (text) => Utils.validatePassword(text!),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: Styles.inputDecoration.copyWith(
                hintText: 'Password',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => TextFormField(
              controller: controller.passwordConfirmController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: controller.obscure(),
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (text) => controller.confirm,
              validator: (text) => Utils.validatePassword(text!),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: Styles.inputDecoration.copyWith(
                hintText: 'Confirm Password',
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Use a password that has at least 8 characters, one uppercase letter, one lowercase letter, and one symbol',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: controller.confirm,
                label: const Text('Confirm'),
                icon: const Icon(LineIcons.check),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: controller.generate,
                label: const Text('Generate'),
                icon: const Icon(LineIcons.flask),
              ),
            ],
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Container(
            constraints: Styles.containerConstraints,
            child: controller.obx(
              (_) => SingleChildScrollView(child: content),
              onLoading: const BusyIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
