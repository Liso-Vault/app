import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';
import '../../app/routes.dart';
import 'category_picker_screen.controller.dart';

class CategoryPickerScreen extends StatelessWidget with ConsoleMixin {
  const CategoryPickerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryPickerScreenController());

    Widget itemBuilder(context, index) {
      final category = controller.data[index];

      void open() async {
        Get.back();

        Utils.adaptiveRouteOpen(
          name: AppRoutes.item,
          parameters: {'mode': 'add', 'category': category.id},
        );
      }

      final icon = AppUtils.categoryIcon(
        category.id,
        color: themeColor,
        size: 40,
      );

      return Card(
        child: InkWell(
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                icon,
                const SizedBox(height: 20),
                Text(category.reservedName),
              ],
            ),
          ),
        ),
      );
    }

    const delegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 200,
      childAspectRatio: 3 / 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    );

    final content = GridView.builder(
      gridDelegate: delegate,
      itemCount: controller.data.length,
      itemBuilder: itemBuilder,
      padding: const EdgeInsets.all(20),
    );

    final appBar = AppBar(
      title: const Text('Choose a template'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    return Scaffold(appBar: appBar, body: content);
  }
}
