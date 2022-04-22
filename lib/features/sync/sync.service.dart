import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

class SyncService extends GetxService with ConsoleMixin {
  static SyncService get to => Get.find();

  // VARIABLES

  // PROPERTIES
  // final inSync = false.obs;
  // final syncing = false.obs;
  // final upSyncing = false.obs;
  // final downSyncing = false.obs;

  // GETTERS
  // bool get syncing => upSyncing.value || downSyncing.value;

  // FUNCTIONS
  // void sync() async {
  //   if (syncing.value) return console.warning('already down syncing');
  //   syncing.value = true;
  //   await S3Service.to.tryDownSync();
  //   syncing.value = false;
  //   MainScreenController.to.load();

  //   // if (syncing) return console.warning('already syncing');
  //   // final changes = PersistenceService.to.changes.val;

  //   // if (changes > 0) {
  //   //   console.warning('pending changes: $changes');
  //   //   upSync();
  //   // } else {
  //   //   downSync();
  //   // }
  // }

  // Future<void> downSync() async {
  //   if (downSyncing.value) return console.warning('already down syncing');
  //   downSyncing.value = true;
  //   await S3Service.to.tryDownSync();
  //   downSyncing.value = false;
  //   MainScreenController.to.load();
  // }

  // Future<void> upSync() async {
  //   if (upSyncing.value) return console.warning('already up syncing');

  //   if (!inSync.value) {
  //     // try down syncing again before up syncing
  //     await downSync();
  //     if (!inSync.value) return console.warning('not in sync');
  //   }

  //   upSyncing.value = true;
  //   final result = await S3Service.to.upSync();
  //   upSyncing.value = false;

  //   if (result.isLeft) {
  //     return UIUtils.showSimpleDialog(
  //       'Error Syncing',
  //       '${result.left} > sync()',
  //     );
  //   }

  //   if (!result.right) return;
  //   PersistenceService.to.changes.val = 0;
  //   NotificationsManager.notify(
  //     title: 'Successfully Synced',
  //     body: 'Your vault just got updated.',
  //   );
  // }
}
