import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/resources/resources.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sign_in_screen.controller.dart';

class SignInScreen extends GetView<SignInScreenController> with ConsoleMixin {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInScreenController());

    final _content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'by Stackwares',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 15),
            const Text(
              "The Social Network that let's you express your true self and emotions anonymously on a worldwide public feed.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontFamily: 'ProductSans'),
            ),
            const Divider(),
            SignInButton(
              onPressed: controller.googleSignIn,
              icon: Image.asset(Images.google, width: 20),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: controller.list,
              child: const Text('List'),
            ),
            TextButton(
              onPressed: controller.upload,
              child: const Text('Upload'),
            ),
            TextButton(
              onPressed: controller.download,
              child: const Text('Download'),
            ),
            TextButton(
              onPressed: controller.empty,
              child: const Text('Empty'),
            ),
          ],
        ),
      ),
    );

    final appBar = AppBar(
      title: const Text(
        'Sign In', // TODO: localize
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );

    final bottomBar = BottomAppBar(
      notchMargin: 4.0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agreement',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => launch(kAppTermsUrl),
                  child: const Text(
                    'Terms',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () => launch(kAppPrivacyUrl),
                  child: const Text(
                    'Privacy',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomBar,
      body: Visibility(
        visible: controller.state == RxStatus.loading(),
        child: const BusyIndicator(message: 'Please wait...'),
        replacement: Center(child: _content),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  final Widget icon;
  final Text label;
  final Color? color;
  final Function()? onPressed;

  const SignInButton({
    Key? key,
    required this.icon,
    required this.label,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: ElevatedButton.styleFrom(
        primary: color,
        minimumSize: const Size(300, 35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
