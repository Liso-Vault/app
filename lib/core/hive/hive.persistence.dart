import 'package:hive/hive.dart';

class HivePersistence {
  late final Box box;

  late String _theme;

  String get theme {
    return _theme;
  }

  set theme(String value) {
    _theme = value;
  }
}
