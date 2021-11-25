import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';

import 'create_password_screen.controller.dart';

class CreatePasswordScreen extends GetView<CreatePasswordScreenController>
    with ConsoleMixin {
  const CreatePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
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
          'This will be the password to unlock $kName',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: controller.passwordController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          textInputAction: TextInputAction.next,
          decoration: Styles.inputDecoration.copyWith(
            hintText: 'Password',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller.passwordConfirmController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          textInputAction: TextInputAction.send,
          onSubmitted: (text) => controller.confirm,
          decoration: Styles.inputDecoration.copyWith(
            hintText: 'Confirm Password',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Use a password that has at least 8 characters, one uppercase letter, one lowercase letter, and one symbol',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: controller.confirm,
          label: const Text('Confirm'),
          icon: const Icon(LineIcons.check),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Container(
              constraints: Styles.containerConstraints,
              child: controller.obx(
                (_) => content,
                onLoading: const BusyIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
