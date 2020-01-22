import 'package:hashcash_dart/hashcash_dart.dart';

void main() {
  print('Hashcash Protocol version: ${Hashcash.version}');

  var stamp = Hashcash.mint('konstantinullrich12@gmail.com');

  print(Hashcash.check(stamp, resource: 'konstantinullrich12@gmail.com'));
}
