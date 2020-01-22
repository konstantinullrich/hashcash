import 'package:hashcash/hashcash.dart';

void main() {
  var minter = Minter();
  print('Hashcash Protocol version: ${minter.version}');
  print(minter.mint('Konsti'));

}
