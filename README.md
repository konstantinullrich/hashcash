# Hashcash
Hashcash is a proof-of-work algorithm, which has been used as a denial-of-service counter measure technique in a 
number of systems.

A hashcash stamp constitutes a proof-of-work which takes a parameterizable amount of work to compute for the sender. 
The recipient (and indeed anyone as it is publicly auditable) can verify received hashcash stamps efficiently. 
Hashcash was invented by [Adam Back][cypherspace] in [1997][papers]

At this point it is most widely used as the [bitcoin][bitcoin] mining function.

The email anti-spam tool, like the proof-of-work algorithm, is also called hashcash and is used to create stamps to 
attach to mail to add a micro-cost to sending mail to deter spamming. The main use of the hashcash stamp is as a 
white-listing hint to help hashcash users avoid losing email due to content based and blacklist based anti-spam systems.

Hashcash source code includes a library form, and also the algorithm is extremely simple to code from scratch with the 
availability of a hash library. Verification can be done by a human eye (count leading 0s) even with availability of 
common preinstalled command line tools such as sha1sum. The algorithm works with a cryptographic hash, such as SHA1, 
SHA256 or coming SHA3 that exhibits 2nd-preimage resistance. Note that 2nd-preimage resistance is a stronger hash 
property than the collision resistance property.


## Usage

A simple example:

```dart
import 'package:hashcash/hashcash.dart';

main() {
  var stamp = Hashcash.mint('konstantinullrich12@gmail.com');
  var checked = Hashcash.check(stamp, resource: 'konstantinullrich12@gmail.com');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[cypherspace]: http://www.cypherspace.org/adam/
[papers]: http://hashcash.org/papers/
[bitcoin]: http://bitcoin.it/
[tracker]: https://github.com/konstantinullrich/hashcash/issues
