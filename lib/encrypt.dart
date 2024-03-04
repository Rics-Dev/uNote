import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class EncryptData {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<String> encryptString(String plainText) async {
    final key = await getSecureKey();
    final iv = IV.fromLength(16); // Generate a new IV for each encryption

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final ivBase64 = base64Encode(iv.bytes); // Convert IV to base64

    // Store IV and encrypted text together in secure storage
    final uniqueId = generateUniqueId(); // You should implement this
    await secureStorage.write(key: uniqueId + '_iv', value: ivBase64);
    await secureStorage.write(
        key: uniqueId + '_encrypted_text', value: encrypted.base64);

    return uniqueId; // Return the unique ID for reference
  }

  Future<String> decryptString(String uniqueId) async {
    final key = await getSecureKey();

    // Retrieve IV and encrypted text from secure storage using the unique ID
    final ivBase64 = await secureStorage.read(key: uniqueId + '_iv');
    final encryptedTextBase64 =
        await secureStorage.read(key: uniqueId + '_encrypted_text');

    if (ivBase64 == null || encryptedTextBase64 == null) {
      return 'No encrypted data found';
    }

    final iv = IV.fromBase64(ivBase64); // Convert IV back from base64
    final encrypted = Encrypted.fromBase64(encryptedTextBase64);

    final decrypter = Encrypter(AES(key));
    final decrypted = decrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }

  Future<Key> getSecureKey() async {
    final keyString = await secureStorage.read(key: 'encryption_key');
    if (keyString == null) {
      final key = await generateSecureKey();
      await secureStorage.write(key: 'encryption_key', value: key.base64);
      return key;
    }
    return Key.fromBase64(keyString);
  }

  Future<Key> generateSecureKey() async {
    // 1. Use a cryptographically secure random number generator
    final random = Random.secure();

    // 2. Generate a sufficiently large random byte array (32 bytes for AES-256)
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));

    // 3. Optionally hash the key for added security (consider SHA-256 or stronger)
    final hashedKeyBytes = sha256.convert(keyBytes).bytes;

    // 4. Create the Key object (replace with appropriate Key class)
    return Key.fromBase64(base64Encode(hashedKeyBytes));
  }

  String generateUniqueId() {
    var uuid = Uuid();
    return uuid.v4();
  }
}

// import 'dart:math';

// import 'package:cryptography/cryptography.dart';
// import 'package:cryptography_flutter/cryptography_flutter.dart';
// import 'package:encrypt/encrypt.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:uuid/uuid.dart';

// class EncryptData {
//   final FlutterSecureStorage secureStorage = FlutterSecureStorage();

//   Future<String> encryptString(String plainText) async {
//     final key = await getSecureKey();
//     final iv = IV.fromSecureRandom(16); // Generate a new IV for each encryption

//     final encrypter = Encrypter(AES(key));
//     final encrypted = encrypter.encrypt(plainText, iv: iv);
//     final ivBase64 = base64Encode(iv.bytes); // Convert IV to base64

//     // Store IV and encrypted text together in secure storage
//     final uniqueId = generateUniqueId(); // You should implement this
//     await secureStorage.write(key: uniqueId + '_iv', value: ivBase64);
//     await secureStorage.write(
//         key: uniqueId + '_encrypted_text', value: encrypted.base64);

//     return uniqueId; // Return the unique ID for reference
//   }

//   Future<String> decryptString(String uniqueId) async {
//     final key = await getSecureKey();

//     // Retrieve IV and encrypted text from secure storage using the unique ID
//     final ivBase64 = await secureStorage.read(key: uniqueId + '_iv');
//     final encryptedTextBase64 =
//         await secureStorage.read(key: uniqueId + '_encrypted_text');

//     if (ivBase64 == null || encryptedTextBase64 == null) {
//       return 'No encrypted data found';
//     }

//     final iv = IV.fromBase64(ivBase64); // Convert IV back from base64
//     final encrypted = Encrypted.fromBase64(encryptedTextBase64);

//     final decrypter = Encrypter(AES(key));
//     final decrypted = decrypter.decrypt(encrypted, iv: iv);

//     return decrypted;
//   }

//   Future<Key> getSecureKey() async {
//     final keyString = await secureStorage.read(key: 'encryption_key');
//     if (keyString == null) {
//       final key = await generateSecureKey();
//       await secureStorage.write(key: 'encryption_key', value: key.base64);
//       return key;
//     }
//     return Key.fromBase64(keyString);
//   }

// Future<Key> generateSecureKey() async {
//   // Use a key derivation function for more secure key generation
//   final password = generateRandomPassword();
//   final salt = generateRandomSalt();
//   final pbkdf2Key = await generatePBKDF2Key(password, salt);

//   return pbkdf2Key;
// }

// Future<Key> generatePBKDF2Key(String password, List<int> salt) async {
//   final keyBytes = await FlutterPbkdf2(
//     macAlgorithm: Hmac.sha256(), // Use a strong MAC algorithm like HMAC-SHA256
//     iterations: 65536, // 20k iterations for a reasonable level of protection
//     bits: 256, // 256 bits = 32 bytes output
//   ).deriveKey(
//     secretKey: SecretKey(Uint8List.fromList(utf8.encode(password))), // Provide a secret key
//     nonce: salt, // Provide a nonce
//   );

//   return Key.fromBase64(base64Encode(keyBytes as List<int>));
// }

//   String generateRandomPassword() {
//     // Generate a sufficiently random password
//     final random = Random.secure();
//     return List.generate(32, (_) => random.nextInt(256)).toString();
//   }

//   Uint8List generateRandomSalt() {
//     final random = Random.secure();
//     return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
//   }

//   String generateUniqueId() {
//     var uuid = Uuid();
//     return uuid.v4();
//   }
// }
