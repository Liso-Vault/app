import 'dart:io';

import 'package:liso/resources/resources.dart';
import 'package:test/test.dart';

void main() {
  test('images assets test', () {
    expect(File(Images.google).existsSync(), true);
    expect(File(Images.logo).existsSync(), true);
    expect(File(Images.placeholder).existsSync(), true);
    expect(File(Images.splash).existsSync(), true);
  });
}
