import 'package:logger/logger.dart';

mixin ConsoleMixin {
  Console get console => Console(name: runtimeType.toString());
}

class Console {
  final String name;
  Console({required this.name});

  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 1,
      noBoxingByDefault: true,
    ),
  );

  void info(String message) => log(Level.info, message);
  void debug(String message) => log(Level.debug, message);
  void warning(String message) => log(Level.warning, message);
  void error(String message) => log(Level.error, message);
  void wtf(String message) => log(Level.wtf, message);
  void verbose(String message) => log(Level.verbose, message);

  void log(Level level, String message) {
    logger.log(level, '$name: $message');
  }
}
