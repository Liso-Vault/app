import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';

class ExportedSourceFormat {
  final String name;
  final String extension;

  ExportedSourceFormat(this.name, this.extension);

  String get id => '${name.toLowerCase()}-$extension';
  String get title => '$name ($extension)';
}

final sourceFormats = [
  ExportedSourceFormat('Bitwarden', 'json'),
  ExportedSourceFormat('Bitwarden', 'csv'),
  ExportedSourceFormat('Chrome', 'csv'),
  ExportedSourceFormat('LastPass', 'csv'),
];

const kAllowedExtensions = ['json', 'csv', 'xml'];

const kChromeCSVColumns = [
  'name',
  'url',
  'username',
  'password',
];

const kBitwardenCSVColumns = [
  'folder',
  'favorite',
  'type',
  'name',
  'notes',
  'fields',
  'reprompt',
  'login_uri',
  'login_username',
  'login_password',
  'login_totp'
];

const kLastPassCSVColumns = [
  'url',
  'username',
  'password',
  'totp',
  'extra',
  'name',
  'grouping',
  'fav'
];

class ImportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final csvConverter = const CsvToListConverter();
  final formKey = GlobalKey<FormState>();
  final filePathController = TextEditingController();
  final sourceFormat = sourceFormats.first.obs;

  // PROPERTIES
  final busy = false.obs;

  // GETTERS

  Future<bool> get canPop async => !busy.value;

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS

  Future<void> _importBitwardenCSV(String contents) async {
    final values = csvConverter.convert(contents, eol: '\n');
    console.info('csv values: $values');

    final columns = values.first.cast<String>();
    console.wtf('csv columns: $columns -> $kBitwardenCSVColumns');

    if (!listEquals(columns, kBitwardenCSVColumns)) {
      change(null, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid Bitwarden CSV exported file',
      );
    }

    change(null, status: RxStatus.success());
  }

  Future<void> _importChromeCSV(String contents) async {
    final values = csvConverter.convert(contents);
    console.info('csv values: $values');

    final columns = values.first;
    console.wtf('csv columns: $columns -> $kChromeCSVColumns');

    if (!listEquals(columns, kChromeCSVColumns)) {
      change(null, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid Chrome CSV exported file',
      );
    }

    change(null, status: RxStatus.success());
  }

  Future<void> _importLastPassCSV(String contents) async {
    final values = csvConverter.convert(contents, eol: '\n');

    console.info('csv values: $values');

    final columns = values.first.sublist(0, kLastPassCSVColumns.length);
    console.wtf('csv columns: $columns -> $kLastPassCSVColumns');

    if (!listEquals(columns, kLastPassCSVColumns)) {
      change(null, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid LastPass CSV exported file',
      );
    }

    change(null, status: RxStatus.success());
  }

  Future<void> _importCSV(String contents) async {
    final formatId = sourceFormat.value.id;

    if (formatId == 'bitwarden-csv') {
      _importBitwardenCSV(contents);
    } else if (formatId == 'chrome-csv') {
      _importChromeCSV(contents);
    } else if (formatId == 'lastpass-csv') {
      _importLastPassCSV(contents);
    }
  }

  Future<void> _importJSON(String contents) async {
    //

    change(null, status: RxStatus.success());
  }

  Future<void> _importXML(String contents) async {
    //

    change(null, status: RxStatus.success());
  }

  Future<void> _proceed() async {
    // // do the actual import

    // const itemCount = 0; // TODO: replace this later

    // MainScreenController.to.load();

    // NotificationsManager.notify(
    //   title: 'Import Successful',
    //   body: 'Successfully imported $itemCount items',
    // );

    // Get.offNamedUntil(Routes.main, (route) => false);

    final file = File(filePathController.text);

    if (!(await file.exists())) {
      Get.back();

      return UIUtils.showSimpleDialog(
        'File Not Found',
        'Please make sure the file: ${file.path} exists.',
      );
    }

    final fileExtension = extension(file.path);

    if (fileExtension != '.${sourceFormat.value.extension}') {
      Get.back();

      return UIUtils.showSimpleDialog(
        'Incorrect File Format',
        'Import the correct file with format: ${sourceFormat.value.title}',
      );
    }

    change(null, status: RxStatus.loading());
    // create a backup
    await LisoManager.createBackup();
    // read contents of file
    final contents = await file.readAsString();
    // catch empty exported file
    if (contents.isEmpty) {
      Get.back();

      return UIUtils.showSimpleDialog(
        'Empty File',
        'Please import a valid exported file',
      );
    }

    // close confirm dialog
    Get.back();

    if (extension(file.path) == '.json') {
      _importJSON(contents);
    } else if (extension(file.path) == '.csv') {
      _importCSV(contents);
    } else if (extension(file.path) == '.xml') {
      _importXML(contents);
    }
  }

  Future<void> continuePressed() async {
    // if (status == RxStatus.loading()) return console.error('still busy');
    // if (!formKey.currentState!.validate()) return;

    // await UIUtils.showImageDialog(
    //   Icon(Iconsax.import, size: 100, color: themeColor),
    //   title: 'Import Items',
    //   subTitle: basename(filePathController.text),
    //   body:
    //       "Are you sure you want to import the items from this exported file to your vault?",
    //   action: _proceed,
    //   actionText: 'Import',
    //   closeText: 'Cancel',
    //   onClose: () {
    //     change(null, status: RxStatus.success());
    //     Get.back();
    //   },
    // );

    const contents = """url,username,password,totp,extra,name,grouping,fav
http://sn,,,,With require master prompt,Secure Note Lastpass,,0
http://sn,,,,"NoteType:Address
Language:en-US
Title:mr
First Name:Oliver
Middle Name:Diotay
Last Name:Martinez
Username:username
Gender:m
Birthday:October,3,1992
Company:Stackwares
Address 1:Address 1
Address 2:Address 2
Address 3:Address 3
City / Town:Talisay
County:Zone 12-A
State:Negros Occidental
Zip / Postal Code:6115
Country:PH
Timezone:+08:00,0
Email Address:nemoryoliver@gmail.com
Phone:{""num"":""639993660119"",""ext"":""20"",""cc3l"":""PHL""}
Evening Phone:
Mobile Phone:
Fax:
Notes:Some notes",Address Lastpass,,1
http://sn,,,,"NoteType:Credit Card
Language:en-US
Name on Card:Oliver Martinez
Type:Visa
Number:00000000000000
Security Code:031
Start Date:February,20
Expiration Date:April,10
Notes:Notes",Payment Card Lastpass,,0
http://sn,,,,"NoteType:Bank Account
Language:en-US
Bank Name:UnionBank
Account Type:Savings
Routing Number:000000
Account Number:0000000000
SWIFT Code:0KJDS0
IBAN Number:KSD0123
Pin:616261
Branch Address:Mandalagan
Branch Phone:09993660119
Notes:Notes",Bank Account Lastpass,,0
http://sn,,,,"NoteType:Driver's License
Language:en-US
Number:000000
Expiration Date:January,10,2022
License Class:
Name:
Address:
City / Town:
State:
ZIP / Postal Code:
Country:
Date of Birth:,,
Sex:
Height:
Notes:Notes",Driver License Personal Lastpass,Personal,0
http://sn,,,,"NoteType:Passport
Language:en-US
Type:Type
Name:Name
Country:Philippines
Number:
Sex:
Nationality:
Issuing Authority:
Date of Birth:,,
Issued Date:,,
Expiration Date:,,
Notes:Notes",Passport Sub Personal,Personal\Sub Personal,0
http://sn,,,,"NoteType:Social Security
Language:en-US
Name:Oliver Martinez
Number:0000000
Notes:Notes",Social Security Lastpass,,0
http://sn,,,,"NoteType:Insurance
Language:en-US
Company:Stackwares
Policy Type:
Policy Number:
Expiration:,,
Agent Name:
Agent Phone:
URL:
Notes:",Insurance Policy,Personal\Sub Personal,0
http://sn,,,,"NoteType:Health Insurance
Language:en-US
Company:Stackwares
Company Phone:00000000
Policy Type:
Policy Number:
Group ID:
Member Name:
Member ID:
Physician Name:
Physician Phone:
Physician Address:
Co-pay:
Notes:",Health Insurance Personal Lastpass,Personal,0
http://xn--login autologin disable autofill-,username,password,,Notes,Facebook Lastpass,Social,1
http://sn,,,,"NoteType:Membership
Language:en-US
Organization:Stackwares Lastpass
Membership Number:
Member Name:
Start Date:,,
Expiration Date:,,
Website:
Telephone:
Password:password
Notes:",Membership Lastpass,,0
http://sn,,,,,Secure Note with Attachment Lastpass,,0
""";

    final values = csvConverter.convert(
      contents,
      eol: '\n',
    );

    console.info('csv columns length: ${values.length}');

    final columns = values.first.sublist(0, kLastPassCSVColumns.length);

    if (!listEquals(columns, kLastPassCSVColumns)) {
      change(null, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Invalid CSV Columns',
        'Please import a valid LastPass CSV exported file',
      );
    }

    // final metadata = await HiveMetadata.get();

    // final items = values.map(
    //   (e) {
    //     return HiveLisoItem(
    //       identifier: const Uuid().v4(),
    //       // groupId: groupId,
    //       // category: category,
    //       title: e[5],
    //       fields: fields,
    //       favorite: e[7] == 1,
    //       // iconUrl: iconUrl.value,
    //       appIds: appIds,
    //       domains: domains,
    //       tags: [sourceFormat.value.name.toLowerCase()],
    //       metadata: metadata,
    //     );
    //   },
    // ).toList();

    // for (var row in values) {
    //   // final grouping = row[6];
    //   // final extra = row[4];
    //   // console.info('extra: ${row[4].split('\n')}');

    //   console.warning('url: ${row[0]}');
    //   console.warning('username: ${row[1]}');
    //   console.warning('password: ${row[2]}');
    //   console.warning('totp: ${row[3]}');
    //   console.warning('name: ${row[5]}');
    //   console.warning('grouping: ${row[6]}');
    //   console.warning('fav: ${row[7]}');
    //   console.debug('extra: ${row[4].split('\n')}');

    //   console.info('############');
    // }
  }

  void importFile() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (GetPlatform.isAndroid) FilePicker.platform.clearTemporaryFiles();
    change(null, status: RxStatus.loading());

    Globals.timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: kAllowedExtensions,
      );
    } catch (e) {
      Globals.timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    change(null, status: RxStatus.success());

    if (result == null || result.files.isEmpty) {
      Globals.timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    final fileExtension = extension(result.files.single.path!);

    if (!kAllowedExtensions.contains(fileExtension.replaceAll('.', ''))) {
      return UIUtils.showSimpleDialog(
        'Invalid File Extension',
        'Allowed file extensions are ${kAllowedExtensions.join(',')}',
      );
    }

    filePathController.text = result.files.single.path!;
  }
}
