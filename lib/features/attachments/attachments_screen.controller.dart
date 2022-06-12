import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';

import '../app/routes.dart';
import '../s3/s3.service.dart';

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
    final filesParam = Get.parameters['attachments']!;
    if (filesParam.isNotEmpty) data.value = filesParam.split(',');
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void pick() async {
    final eTag = await Utils.adaptiveRouteOpen(
      name: Routes.s3Explorer,
      parameters: {'type': 'picker'},
    );

    if (eTag == null) return;
    final exists = data.contains(eTag);

    if (exists) {
      final content = S3Service.to.contentsCache.firstWhere(
        (e) => e.object!.eTag == eTag,
      );

      return UIUtils.showSimpleDialog(
        'Already Exists',
        'Attachment: ${content.name} is already attached to this item',
      );
    }

    data.add(eTag);
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }
}
