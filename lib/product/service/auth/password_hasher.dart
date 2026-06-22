import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// PBKDF2-HMAC-SHA256 password hashing utilities.
final class PasswordHasher {
  PasswordHasher({
    this.defaultIterations = 100000,
    this.saltLength = 32,
  });

  static const int hashByteLength = 32;

  final int defaultIterations;
  final int saltLength;

  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(saltLength, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  Future<String> hashPassword({
    required String password,
    required String salt,
    required int iterations,
  }) async {
    final saltBytes = base64Decode(salt);
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: hashByteLength * 8,
    );
    final secretKey = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: saltBytes,
    );
    final hashBytes = await secretKey.extractBytes();
    return base64Encode(hashBytes);
  }

  Future<bool> verifyPassword({
    required String password,
    required String salt,
    required String hash,
    required int iterations,
  }) async {
    final computedHash = await hashPassword(
      password: password,
      salt: salt,
      iterations: iterations,
    );
    return _constantTimeEquals(
      base64Decode(computedHash),
      base64Decode(hash),
    );
  }

  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
