import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;

/// Checks if you are awesome. Spoiler: you are.
class Hashcash {
  static final int _version = 1;
  static final String _ascii_chars =
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
  ///    'saltchars' specifies the length of the salt used; this version defaults
  ///    8 chars, rather than the C version's 16 chars.  This still provides about
  ///    17 million salts per resource, per timestamp, before birthday paradox
  ///    collisions occur.  Really paranoid users can use a larger salt though.
  ///
  ///    'stamp_seconds' lets you add the option time elements to the datestamp.
  ///    If you want more than just day, you get all the way down to seconds,
  ///    even though the spec also allows hours/minutes without seconds.
  static String mint(String resource,
      {int bits = 20,
      DateTime now,
      String extension = '',
      int saltchars = 8,
      bool stamp_seconds = false}) {
    var iso_now =
        now == null ? DateTime.now().toIso8601String() : now.toIso8601String();
    iso_now = iso_now.replaceAll('-', '').replaceAll(':', '');
    var date_time = iso_now.split('T');
    var ts = date_time[0].substring(2, date_time.length);
    if (stamp_seconds) {
      ts = '$ts${date_time[1].substring(0, 6)}';
    }

    var challenge = <String>[
      version.toString(),
      bits.toString(),
      ts,
      resource,
      extension,
      _salt(saltchars)
    ];

    var mint = _mint(challenge.join(':'), bits);
    challenge.add(mint);
    return challenge.join(':');
  }

  /// Return a random string of specified length
  static String _salt(int length) {
    var random = Random();
    var result = '';
    for (var i = 0; i < length; i++) {
      result += _ascii_chars[random.nextInt(_ascii_chars.length)];
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
    var counter = 0;
    var hex_digets = (bits / 4).ceil();
    var zeros = '0' * hex_digets;
    while (true) {
      var digest = crypto.sha1
          .convert((challenge + ':' + counter.toRadixString(16)).codeUnits)
          .toString();
      if (digest.startsWith(zeros)) {
        return counter.toRadixString(16);
      }
      counter++;
    }
  }

  static bool check(String stamp,
      {String resource, int bits = 20, Duration check_expiration}) {
    if (stamp == null || stamp.isEmpty) {
      return false;
    }
    if (stamp.startsWith('0:')) {
      var stamp_parts = stamp.substring(2).split(':');
      if (stamp_parts.length != 3) {
        return false;
      }

      var date = stamp_parts[0];
      var res = stamp_parts[1];

      var dt = _currentDate(date);
      if (dt == null) {
        return false;
      }

      if (resource != null && resource != res) {
        return false;
      }
      if (check_expiration != null) {
        var good_until = dt.add(check_expiration);
        var now = DateTime.now();
        if (now.isAfter(good_until)) {
          return false;
        }
      }
      var hex_digits = (bits / 4).floor();
      return crypto.sha1
          .convert(stamp.codeUnits)
          .toString()
          .startsWith('0' * hex_digits);
    } else if (stamp.startsWith('1:')) {
      var stamp_parts = stamp.substring(2).split(':');
      if (stamp_parts.length != 6) {
        return false;
      }

      var claim = int.parse(stamp_parts[0]);
      var date = stamp_parts[1];
      var res = stamp_parts[2];

      var dt = _currentDate(date);
      if (dt == null) {
        return false;
      }

      if (resource != null && resource != res) {
        return false;
      }
      if (bits != null && bits > claim) {
        return false;
      }
      if (check_expiration != null) {
        var good_until = dt.add(check_expiration);
        var now = DateTime.now();
        if (now.isAfter(good_until)) {
          return false;
        }
      }
      var hex_digits = (claim / 4).floor();
      return crypto.sha1
          .convert(stamp.codeUnits)
          .toString()
          .startsWith('0' * hex_digits);
    } else {
      if (resource != null && !stamp.contains(resource)) {
        return false;
      }
      var hex_digits = (bits / 4).floor();
      return crypto.sha1
          .convert(stamp.codeUnits)
          .toString()
          .startsWith('0' * hex_digits);
    }
  }

  static DateTime _currentDate(String date) {
    var day = int.parse(date.substring(4, 6), onError: (e) => null);
    var month = int.parse(date.substring(2, 4), onError: (e) => null);
    var year = int.parse(date.substring(0, 2), onError: (e) => null);
    if (day == null || month == null || year == null) {
      return null;
    }
    int hour;
    int minute;
    if (date.length >= 10) {
      hour = int.parse(date.substring(6, 8), onError: (e) => null);
      minute = int.parse(date.substring(8, 10), onError: (e) => null);
      if (hour == null || minute == null) {
        return null;
      }
    }
    DateTime dt;
    if (hour != null && minute != null) {
      dt = DateTime(year + 2000, month, day, hour, minute);
    } else {
      dt = DateTime(year + 2000, month, day);
    }
    return dt;
  }
}
