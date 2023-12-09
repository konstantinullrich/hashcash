import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;

class Hashcash {
  static final int _version = 1;
  static final String _asciiChars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/=';

  /// Version of the implemented hashcash protocol
  /// Warning: This version has nothing to do with the version fo the Package
  /// stated in the pubspec.yaml file
  static int get version => _version;

  /// Mint a new hashcash stamp for 'resource' with 'bits' of collision
  ///
  ///    20 bits of collision is the default.
  ///
  ///    'ext' lets you add your own extensions to a minted stamp.  Specify an
  ///    extension as a string of form 'name1=2,3;name2;name3=var1=2,2,val'
  ///    FWIW, urllib.urlencode(dct).replace('&',';') comes close to the
  ///    hashcash extension format.
  ///
  ///    'saltChars' specifies the length of the salt used; this version defaults
  ///    8 chars, rather than the C version's 16 chars.  This still provides about
  ///    17 million salts per resource, per timestamp, before birthday paradox
  ///    collisions occur.  Really paranoid users can use a larger salt though.
  ///
  ///    'stamp_seconds' lets you add the option time elements to the datestamp.
  ///    If you want more than just day, you get all the way down to seconds,
  ///    even though the spec also allows hours/minutes without seconds.
  static String mint(String resource,
      {int bits = 20,
      DateTime? now,
      String extension = '',
      int saltChars = 8,
      bool stampSeconds = false}) {
    var isoNow = now?.toIso8601String() ?? DateTime.now().toIso8601String();
    isoNow = isoNow.replaceAll('-', '').replaceAll(':', '');
    final dateTime = isoNow.split('T');
    var ts = dateTime[0].substring(2, dateTime[0].length);

    if (stampSeconds) {
      ts = '$ts${dateTime[1].substring(0, 6)}';
    }

    final challenge = <String>[
      version.toString(),
      bits.toString(),
      ts,
      resource,
      extension,
      _salt(saltChars)
    ];

    final mint = _mint(challenge.join(':'), bits);
    challenge.add(mint);
    return challenge.join(':');
  }

  /// Return a random string of specified length
  static String _salt(int length) {
    final random = Random();
    var result = '';
    for (var i = 0; i < length; i++) {
      result += _asciiChars[random.nextInt(_asciiChars.length)];
    }
    return result;
  }

  /// Answer a 'generalized hashcash' challenge'
  ///
  /// Hashcash requires stamps of form 'ver:bits:date:res:ext:rand:counter'
  /// This internal function accepts a generalized prefix 'challenge',
  /// and returns only a suffix that produces the requested SHA leading zeros.
  ///
  /// NOTE: Number of requested bits is rounded up to the nearest multiple of 4
  static String _mint(String challenge, int bits) {
    final hexDigits = (bits / 4).ceil();
    final zeros = '0' * hexDigits;
    var counter = 0;

    while (true) {
      final digest = crypto.sha1
          .convert(('$challenge:${counter.toRadixString(16)}').codeUnits)
          .toString();
      if (digest.startsWith(zeros)) return counter.toRadixString(16);
      counter++;
    }
  }

  static bool check(String stamp,
      {String? resource, int bits = 20, Duration? checkExpiration}) {
    if (stamp.isEmpty) return false;

    if (stamp.startsWith('0:')) {
      final stampParts = stamp.substring(2).split(':');

      if (stampParts.length != 3) return false;

      final date = stampParts[0];
      final res = stampParts[1];

      final dt = _currentDate(date);
      if (dt == null) return false;

      if (resource != null && resource != res) return false;

      if (checkExpiration != null) {
        final goodUntil = dt.add(checkExpiration);
        final now = DateTime.now();

        if (now.isAfter(goodUntil)) return false;
      }

      final hexDigits = (bits / 4).floor();
      return crypto.sha1
          .convert(stamp.codeUnits)
          .toString()
          .startsWith('0' * hexDigits);
    } else if (stamp.startsWith('1:')) {
      final stampParts = stamp.substring(2).split(':');
      if (stampParts.length != 6) return false;

      final claim = int.parse(stampParts[0]);
      final date = stampParts[1];
      final res = stampParts[2];
      final dt = _currentDate(date);

      if (dt == null) return false;
      if (resource != null && resource != res) return false;
      if (bits != claim) return false;

      if (checkExpiration != null) {
        final goodUntil = dt.add(checkExpiration);
        final now = DateTime.now();

        if (now.isAfter(goodUntil)) return false;
      }

      final hexDigits = (claim / 4).floor();
      return crypto.sha1
          .convert(stamp.codeUnits)
          .toString()
          .startsWith('0' * hexDigits);
    } else {
      if (resource != null && !stamp.contains(resource)) return false;

      final hexDigits = (bits / 4).floor();
      return crypto.sha1
          .convert(stamp.codeUnits)
          .toString()
          .startsWith('0' * hexDigits);
    }
  }

  static DateTime? _currentDate(String date) {
    final day = int.tryParse(date.substring(4, 6));
    final month = int.tryParse(date.substring(2, 4));
    final year = int.tryParse(date.substring(0, 2));

    if (day == null || month == null || year == null) return null;

    if (date.length >= 10) {
      final hour = int.tryParse(date.substring(6, 8));
      final minute = int.tryParse(date.substring(8, 10));

      if (hour == null || minute == null) return null;
      return DateTime(year + 2000, month, day, hour, minute);
    }

    return DateTime(year + 2000, month, day);
  }
}
