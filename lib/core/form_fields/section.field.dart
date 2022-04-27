import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/field.hive.dart';

class SectionFormField extends StatelessWidget {
  final HiveLisoField field;
  const SectionFormField(this.field, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Opacity(
        opacity: 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.data.value!.toUpperCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 10,
                // fontWeight: FontWeight.bold,
                color: Get.theme.primaryColor,
              ),
            ),
            Divider(
              height: 5,
              color: Get.theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
