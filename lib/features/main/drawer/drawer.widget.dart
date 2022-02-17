import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/app/routes.dart';

class ZDrawer extends StatelessWidget {
  const ZDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final address = masterWallet!.privateKey.address.hexEip55;

    // final header = DrawerHeader(
    //   child: Center(
    //     child: InkWell(
    //       onTap: () => Utils.copyToClipboard(address),
    //       child: Text(address),
    //     ),
    //   ),
    // );

    final items = [
      // header,
      const SizedBox(height: 50),
      ListTile(
        title: const Text('Settings'),
        leading: const Icon(LineIcons.cog),
        onTap: () => Get.offAndToNamed(Routes.settings),
      ),
      ListTile(
        title: const Text('About'),
        leading: const Icon(LineIcons.infoCircle),
        onTap: () => Get.offAndToNamed(Routes.about),
      ),
      ListTile(
        title: const Text('Google Drive'),
        leading: const Icon(LineIcons.googleDrive),
        onTap: () => Get.offAndToNamed(Routes.signIn),
      ),
    ];

    final darkTheme = FlexColorScheme.dark(
      scheme: FlexScheme.jungle,
    ).toTheme.copyWith(canvasColor: Colors.grey.shade900);

    return Theme(
      data: darkTheme,
      child: Drawer(
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) => items[index],
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemCount: items.length,
        ),
      ),
    );
  }
}
