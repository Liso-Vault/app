import 'package:console_mixin/console_mixin.dart';
// import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';

class DebugScreenController extends GetxController with ConsoleMixin {
  static DebugScreenController get to => Get.find();

  // VARIABLES
  // final autofill = AutofillService();

  // AutofillPreferences? pref;
  // AutofillMetadata? metadata;
  // AutofillServiceStatus? status;

  @override
  void onInit() {
    if (GetPlatform.isAndroid) updateStats();
    super.onInit();
  }

  Future<void> updateStats() async {
//     pref = await autofill.getPreferences();
//     metadata = await autofill.getAutofillMetadata();
//     status = await autofill.status();

//     console.info(''''
// fillRequestedAutomatic: ${await autofill.fillRequestedAutomatic}'
// fillRequestedInteractive: ${await autofill.fillRequestedInteractive}'
// hasAutofillServicesSupport: ${await autofill.hasAutofillServicesSupport}'
// hasEnabledAutofillServices: ${await autofill.hasEnabledAutofillServices}'

// saveInfo: ${metadata?.saveInfo?.toJson()}'
// packageNames: ${metadata?.packageNames}'
// webDomains: ${metadata?.webDomains}'

// enableDebug: ${pref?.enableDebug}'
// enableSaving: ${pref?.enableSaving}'

// status: ${status.toString()}'
//     ''');
  }

  void save() async {
    // console.info('onSaveComplete...');
    // await AutofillService().onSaveComplete();
    // console.warning('onSaveComplete!');
    // await updateStats();
  }

  void setPreferences() async {
    // console.info('setPreferences...');

    // await AutofillService().setPreferences(AutofillPreferences(
    //   enableDebug: pref!.enableDebug,
    //   enableSaving: pref!.enableSaving,
    // ));

    // console.warning('setPreferences');

    // await updateStats();
  }

  void setAutofillService() async {
    // console.info('setAutofillService...');
    // final response = await AutofillService().requestSetAutofillService();
    // console.warning('setAutofillService: $response');
    // await updateStats();
  }

  void datasets() async {
    // console.info('resultWithDatasets...');

    // final response = await AutofillService().resultWithDatasets([
    //   PwDataset(
    //     label: 'dataset 1',
    //     username: 'theusername1@gmail.com',
    //     password: 'thepassword1',
    //   ),
    //   PwDataset(
    //     label: 'dataset 2',
    //     username: 'theusername2',
    //     password: 'thepassword2',
    //   ),
    //   PwDataset(
    //     label: 'user only',
    //     username: 'theusername',
    //     password: '',
    //   ),
    //   PwDataset(
    //     label: 'password only',
    //     username: '',
    //     password: 'thepassword',
    //   ),
    // ]);

    // console.warning('resultWithDatasets: $response');
    // await updateStats();
  }

  void dataset() async {
    // console.info('resultWithDataset...');

    // final response = await AutofillService().resultWithDataset(
    //   label: 'Label',
    //   username: 'theusername',
    //   password: 'thepassword',
    // );

    // console.warning('resultWithDataset: $response');
    // await updateStats();
  }

  void saveInfo() async {
    // metadata = AutofillMetadata(
    //   packageNames: {'com.instagram.android'},
    //   webDomains: {AutofillWebDomain(domain: 'instagram.com')},
    //   saveInfo: SaveInfoMetadata(username: 'theuser', password: 'thepass'),
    // );

    // if (metadata!.webDomains.isEmpty && metadata!.packageNames.isEmpty) {
    //   return console.error('invalid autofill metadata');
    // }

    // final appDomains = ConfigService.to.appDomains.data.where((e) {
    //   // DOMAINS
    //   if (metadata?.webDomains != null &&
    //       e.uris.where((e) {
    //         final uri = Uri.tryParse(e);
    //         if (uri == null) false;
    //         final domain = AutofillWebDomain(
    //           scheme: uri!.scheme,
    //           domain: uri.host,
    //         );

    //         return metadata!.webDomains.contains(domain);
    //       }).isNotEmpty) {
    //     return true;
    //   }

    //   // PACKAGE NAMES
    //   if (metadata?.packageNames != null &&
    //       e.appIds
    //           .where((a) => metadata!.packageNames.contains(a))
    //           .isNotEmpty) {
    //     return true;
    //   }

    //   return false;
    // }).toList();

    // final appIds = metadata?.packageNames != null
    //     ? metadata!.packageNames.toList()
    //     : <String>[];

    // final uris = metadata?.webDomains != null
    //     ? metadata!.webDomains
    //         .toList()
    //         .map((e) => '${e.scheme}://${e.domain}')
    //         .toList()
    //     : <String>[];

    // String service = '';

    // if (metadata!.packageNames.isNotEmpty) {
    //   service = metadata!.packageNames.first;
    // } else if (metadata!.webDomains.isNotEmpty) {
    //   service = metadata!.webDomains.first.domain;
    // }

    // final appDomain = appDomains.isNotEmpty
    //     ? appDomains.first
    //     : HiveAppDomain(
    //         title: service,
    //         appIds: appIds,
    //         uris: uris,
    //         iconUrl: '',
    //       );

    // console.info('app domain: ${appDomain.toJson()}');

    // final username = metadata?.saveInfo?.username ?? '';
    // final password = metadata?.saveInfo?.password ?? '';

    // Utils.adaptiveRouteOpen(
    //   name: Routes.item,
    //   parameters: {
    //     'mode': 'saved_autofill',
    //     'category': LisoItemCategory.login.name,
    //     'title': '$username ${appDomain.title}',
    //     'username': username,
    //     'password': password,
    //     'app_domain': jsonEncode(appDomain.toJson()),
    //   },
    // );
  }
}
