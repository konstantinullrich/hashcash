import 'dart:io';

import 'package:hashcash_dart/hashcash_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Hashcash Testgroup', () {
    final stamp = Hashcash.mint('dev@konstantinullrich.de', stampSeconds: true);

    test('Wrong Resource', () {
      expect(Hashcash.check(stamp, resource: 'test'), false);
    });

    test('Valid Resource', () {
      expect(Hashcash.check(stamp, resource: 'dev@konstantinullrich.de'), true);
    });

    test('Correct bits', () {
      expect(Hashcash.check(stamp, bits: 20), true);
    });

    test('Smaller bits', () {
      expect(Hashcash.check(stamp, bits: 15), false);
    });

    test('Valid Expiration', () {
      expect(Hashcash.check(stamp, checkExpiration: Duration(hours: 1)), true);
    });

    sleep(Duration(seconds: 10));

    test('Bad Expiration', () {
      expect(
          Hashcash.check(stamp, checkExpiration: Duration(seconds: 1)), false);
    });

    test('More Valid Expiration', () {
      expect(
          Hashcash.check(stamp, checkExpiration: Duration(minutes: 1)), true);
    });
  });
}
