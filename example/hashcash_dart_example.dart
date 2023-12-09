import 'package:hashcash_dart/hashcash_dart.dart';

void main() {
  print('Hashcash Protocol version: ${Hashcash.version}');

  final stamp = Hashcash.mint('dev@konstantinullrich.de');

  print(Hashcash.check(stamp, resource: 'dev@konstantinullrich.de'));
}
