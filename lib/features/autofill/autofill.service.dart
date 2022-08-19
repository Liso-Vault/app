import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';
import 'package:liso/core/notifications/notifications.manager.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/hive/models/app_domain.hive.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../main/main_screen.controller.dart';
import 'autofill_picker/autofill_picker.dialog.dart';

class LisoAutofillService extends GetxService with ConsoleMixin {
  static LisoAutofillService get to => Get.find();

  // VARIABLES
  final autofill = AutofillService();

  AutofillPreferences? pref;
  AutofillMetadata? metadata;
  AutofillServiceStatus? status;

  // PROPERTIES
  final supported = false.obs;
  final enabled = false.obs;
  final saving = false.obs;

  @override
  void onInit() async {
    supported.value = await autofill.hasAutofillServicesSupport;
    if (!supported.value) return;

    enabled.value = await autofill.hasEnabledAutofillServices;

    final pref = await autofill.getPreferences();
    saving.value = pref.enableSaving;

    console.info(
      'supported: ${supported.value}, enabled: ${enabled.value}',
    );

    super.onInit();
  }

  void set() async {
    await autofill.requestSetAutofillService();
    enabled.value = await autofill.hasEnabledAutofillServices;

    NotificationsManager.notify(
      title: 'Autofill Service ${enabled.value ? 'Enabled' : 'Disabled'}',
      body: enabled.value
          ? '${ConfigService.to.appName} will now automatically suggest to fill and save forms for you'
          : 'You can enable this setting again anytime',
    );
  }

  void toggleSaving(bool value) async {
    saving.value = value;

    await autofill.setPreferences(AutofillPreferences(
      enableDebug: false,
      enableSaving: value,
    ));
  }

  void request() async {
    await _refresh();
    // SAVE MODE
    if (metadata?.saveInfo != null) return save();
    // FILL MODE
    String query = '';

    if (metadata!.webDomains.isNotEmpty) {
      query = metadata!.webDomains.first.domain;
    } else {
      query = metadata!.packageNames.first;
    }

    final appDomains = ConfigService.to.appDomains.data.where((e) {
      // DOMAINS
      if (metadata?.webDomains != null &&
          e.uris.where((e) {
            final uri = Uri.tryParse(e);
            if (uri == null) false;
            final domain = AutofillWebDomain(
              scheme: uri!.scheme,
              domain: uri.host,
            );

            return metadata!.webDomains.contains(domain);
          }).isNotEmpty) {
        return true;
      }

      // PACKAGE NAMES
      if (metadata?.packageNames != null &&
          e.appIds
              .where((a) => metadata!.packageNames.contains(a))
              .isNotEmpty) {
        return true;
      }

      return false;
    }).toList();

    MainScreenController.to.search(
      query: appDomains.isNotEmpty ? appDomains.first.title : query,
    );
  }

  void save() {
    final webDomains = metadata!.webDomains;
    final packageNames = metadata!.packageNames;

    if (webDomains.isEmpty && packageNames.isEmpty) {
      return console.error('invalid autofill metadata');
    }

    final appDomains = ConfigService.to.appDomains.data.where((e) {
      // DOMAINS
      if (e.uris.where((e) {
        final uri = Uri.tryParse(e);
        if (uri == null) false;
        final domain = AutofillWebDomain(
          scheme: uri!.scheme,
          domain: uri.host,
        );

        return webDomains.contains(domain);
      }).isNotEmpty) {
        return true;
      }

      // PACKAGE NAMES
      if (e.appIds.where((a) => packageNames.contains(a)).isNotEmpty) {
        return true;
      }

      return false;
    }).toList();

    final appIds = packageNames.toList();

    var uris = webDomains
        .toList()
        .map(
          (e) => '${e.scheme}://${e.domain}',
        )
        .toList();

    if (uris.isEmpty && appDomains.isNotEmpty) {
      uris = appDomains.first.uris;
    }

    String service = '';

    if (packageNames.isNotEmpty) {
      service = packageNames.first;
    } else if (webDomains.isNotEmpty) {
      service = webDomains.first.domain;
    }

    final appDomain = appDomains.isNotEmpty
        ? appDomains.first
        : HiveAppDomain(
            title: service,
            appIds: appIds,
            uris: uris,
            iconUrl: '',
          );

    console.info('app domain: ${appDomain.toJson()}');
    final username = metadata?.saveInfo?.username ?? '';
    final password = metadata?.saveInfo?.password ?? '';

    Utils.adaptiveRouteOpen(
      name: Routes.item,
      parameters: {
        'mode': 'saved_autofill',
        'category': LisoItemCategory.login.name,
        'title': '$username ${appDomain.title}',
        'username': username,
        'password': password,
        'app_domain': jsonEncode(appDomain.toJson()),
      },
    );
  }

  Future<void> fill(HiveLisoItem item) async {
    // USERNAME FIELDS
    final usernameFields = item.usernameFields;
    console.wtf('usernames: ${usernameFields.length}');

    // PASSWORD FIELDS
    final passwordFields = item.passwordFields;
    console.wtf('passwords: ${passwordFields.length}');
    // if single username and password fields found. return right away
    if (usernameFields.length <= 1 && passwordFields.length <= 1) {
      final username =
          usernameFields.isNotEmpty ? usernameFields.first.data.value! : '';
      final password =
          passwordFields.isNotEmpty ? passwordFields.first.data.value! : '';

      final response = await AutofillService().resultWithDatasets([
        PwDataset(
          label: item.title,
          username: username,
          password: password,
        )
      ]);

      return console.warning('resultWithDatasets: $response');
    }

    // if more than 1 username or password, let the user select
    final dataset = await Get.dialog(AutofillPickerDialog(item: item));
    if (dataset == null) console.warning('empty dataset returned');
    console.info('dataset: $dataset');
    final response = await AutofillService().resultWithDatasets(dataset);
    console.warning('resultWithDatasets: $response');
  }

  Future<void> _refresh() async {
    pref = await autofill.getPreferences();
    metadata = await autofill.getAutofillMetadata();
    status = await autofill.status();
  }
}
