import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';

import '../../core/utils/utils.dart';

class AppBarLeadingButton extends StatelessWidget {
  final Function()? action;

  const AppBarLeadingButton({Key? key, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: action ?? Get.back,
      icon: Icon(
        Utils.isDrawerExpandable ? Iconsax.arrow_left_2 : LineIcons.times,
      ),
    );
  }
}
