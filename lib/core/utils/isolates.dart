import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';

class Isolates {
  static final console = Console(name: 'Isolates');

  static String iJsonEncode(dynamic params) {
    return jsonEncode(params);
  }

  static dynamic iJsonDecode(String params) {
    return jsonDecode(params);
  }
}
