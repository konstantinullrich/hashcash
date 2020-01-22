import 'package:hashcash/hashcash.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    Minter minter;

    setUp(() {
      minter = Minter();
    });

    test('Check version', () {
      expect(minter.version, 1);
    });
  });
}
