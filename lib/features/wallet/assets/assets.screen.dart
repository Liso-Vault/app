import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:console_mixin/console_mixin.dart';

import '../../../resources/resources.dart';
import 'assets_screen.controller.dart';

class AssetsScreen extends GetWidget<AssetsScreenController> with ConsoleMixin {
  const AssetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          leading: Image.asset(Images.logo, height: 18, color: Colors.white),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('3,856,516.23 LISO'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(LineIcons.bitcoin),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('5.23 BTC'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(LineIcons.ethereum),
          trailing: const Icon(LineIcons.angleRight),
          title: const Text('281.23 ETH'),
          onTap: () {},
        ),
      ],
    );
  }
}
