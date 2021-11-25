import 'package:get/get.dart';

class Tr {
  static const localeString = "locale_string";
  static const languageString = "language_string";
  static const language = "language";
  static const test = "test";
}

extension TransExt on String {
  String trans([List<String>? args]) {
    String key = tr;

    if (args != null) {
      for (var arg in args) {
        key = key.replaceFirst(
          RegExp(r'@s'),
          arg.toString(),
        );
      }
    }

    return key;
  }
}
