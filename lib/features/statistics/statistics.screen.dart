import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget with ConsoleMixin {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(StatisticsScreenController());

    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: const [
        // Obx(
        //   () => ListTile(
        //     title: Text(
        //       '${controller.dateFormatter.format(controller.dateRange.value.start)} -> ${controller.dateFormatter.format(controller.dateRange.value.end)}',
        //       style: const TextStyle(color: Colors.grey),
        //     ),
        //   ),
        // ),
        // const Divider(),
        // Obx(
        //   () => ListTile(
        //     leading: const Icon(LucideIcons.user),
        //     title: Text('Profiles: ${controller.profilesTitle.value}'),
        //     subtitle: Text(
        //       controller.profilesSubTitle.value,
        //       style: const TextStyle(color: Colors.grey),
        //     ),
        //     onTap: () async {
        //       controller.loadProfiles();
        //     },
        //   ),
        // ),
        // Obx(
        //   () => ListTile(
        //     leading: const Icon(LucideIcons.cpu),
        //     title: Text('Devices: ${controller.devicesTitle.value}'),
        //     subtitle: Text(
        //       controller.devicesSubTitle.value,
        //       style: const TextStyle(color: Colors.grey),
        //     ),
        //     onTap: () async {
        //       controller.loadDevices();
        //     },
        //   ),
        // ),
        // Obx(
        //   () => ListTile(
        //     leading: const Icon(LucideIcons.logIn),
        //     title: Text('Sessions: ${controller.sessionsTitle.value}'),
        //     subtitle: Text(
        //       controller.sessionsSubTitle.value,
        //       style: const TextStyle(color: Colors.grey),
        //     ),
        //     onTap: () async {
        //       controller.loadSessions();
        //     },
        //   ),
        // ),
      ],
    );

    final appBar = AppBar(
      title: const Text('Statistics'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      // actions: [
      //   ElevatedButton(
      //     onPressed: controller.loadAll,
      //     child: const Text('All'),
      //   ),
      //   const SizedBox(width: 5),
      //   IconButton(
      //     onPressed: controller.previous,
      //     icon: const Icon(Icons.arrow_back),
      //   ),
      //   const SizedBox(width: 5),
      //   IconButton(
      //     onPressed: controller.selectDates,
      //     icon: const Icon(Iconsax.calendar_outline),
      //   ),
      //   const SizedBox(width: 5),
      //   IconButton(
      //     onPressed: controller.next,
      //     icon: const Icon(Icons.arrow_forward),
      //   ),
      //   const SizedBox(width: 10),
      // ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
