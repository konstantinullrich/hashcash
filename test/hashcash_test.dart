import 'package:hashcash/hashcash.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('Check version', () {
      expect(Hashcash.version, 1);
    });
  });
}
