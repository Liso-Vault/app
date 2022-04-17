import 'dart:io';

import 'package:liso/resources/resources.dart';
import 'package:test/test.dart';

void main() {
  test('origin_images assets test', () {
    expect(File(OriginImages.bitgo).existsSync(), true);
    expect(File(OriginImages.cano).existsSync(), true);
    expect(File(OriginImages.exodus).existsSync(), true);
    expect(File(OriginImages.mathWallet).existsSync(), true);
    expect(File(OriginImages.metamask).existsSync(), true);
    expect(File(OriginImages.myetherwallet).existsSync(), true);
    expect(File(OriginImages.other).existsSync(), true);
    expect(File(OriginImages.syrius).existsSync(), true);
    expect(File(OriginImages.trustWallet).existsSync(), true);
    expect(File(OriginImages.zenon).existsSync(), true);
  });
}
