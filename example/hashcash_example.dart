import 'package:hashcash/hashcash.dart';

void main() {
  print('Hashcash Protocol version: ${Hashcash.version}');
  print(Hashcash.mint('Konsti'));

}
