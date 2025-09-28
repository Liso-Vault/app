import 'package:app_core/globals.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import '../app/routes.dart';
import '../files/storage.service.dart';

class AttachmentsScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static AttachmentsScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <String>[].obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    final filesParam = gParameters['attachments']!;
    if (filesParam.isNotEmpty) data.value = filesParam.split(',');
    change(data.isEmpty ? GetStatus.empty() : GetStatus.success(null));
    super.onInit();
  }

  // FUNCTIONS

  void pick() async {
    final eTag = await Utils.adaptiveRouteOpen(
      name: AppRoutes.s3Explorer,
      parameters: {'type': 'picker'},
    );

    if (eTag == null) return;
    final exists = data.contains(eTag);

    if (exists) {
      final content = FileService.to.rootInfo.value.data.objects.firstWhere(
        (e) => e.etag == eTag,
      );

      return UIUtils.showSimpleDialog(
        'Already Exists',
        'Attachment: ${content.name} is already attached to this item',
      );
    }

    data.add(eTag);
    change(data.isEmpty ? GetStatus.empty() : GetStatus.success(null));
  }
}
