import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/resources/resources.dart';

import 'about_screen.controller.dart';

class AboutScreen extends GetView<AboutScreenController> {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _content = ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(height: 20),
        Image.asset(Images.logo, height: 50),
        const SizedBox(height: 15),
        const Text(
          kDescription,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: _content,
    );
  }
}
