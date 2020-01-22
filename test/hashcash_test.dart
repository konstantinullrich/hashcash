import 'dart:io';

import 'package:hashcash_dart/hashcash_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Hashcash Testgroup', () {
    var stamp =
        Hashcash.mint('konstantinullrich12@gmail.com', stamp_seconds: true);

    test('Wrong Resource', () {
      expect(Hashcash.check(stamp, resource: 'test'), false);
    });

    test('Valid Resource', () {
      expect(Hashcash.check(stamp, resource: 'konstantinullrich12@gmail.com'),
          true);
    });

    test('Correct bits', () {
      expect(Hashcash.check(stamp, bits: 20), true);
    });

    test('Smaller bits', () {
      expect(Hashcash.check(stamp, bits: 15), false);
    });

    test('Valid Expiration', () {
      expect(Hashcash.check(stamp, check_expiration: Duration(hours: 1)), true);
    });

    sleep(Duration(seconds: 10));

    test('Bad Expiration', () {
      expect(
          Hashcash.check(stamp, check_expiration: Duration(seconds: 1)), false);
    });

    test('More Valid Expiration', () {
      expect(
          Hashcash.check(stamp, check_expiration: Duration(minutes: 1)), true);
    });
  });
}
