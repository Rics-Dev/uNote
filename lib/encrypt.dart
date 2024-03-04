import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class EncryptData {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String> encryptString(String plainText) async {
    final key = await getSecureKey();
    final iv = IV.fromLength(16); // Generate a new IV for each encryption

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final ivBase64 = base64Encode(iv.bytes); // Convert IV to base64

    // Store IV and encrypted text together in secure storage
    final uniqueId = generateUniqueId(); // You should implement this
    await secureStorage.write(key: '${uniqueId}_iv', value: ivBase64);
    await secureStorage.write(key: '${uniqueId}_encrypted_text', value: encrypted.base64);

    return uniqueId; // Return the unique ID for reference
  }

  Future<String> decryptString(String uniqueId) async {
    final key = await getSecureKey();

    // Retrieve IV and encrypted text from secure storage using the unique ID
    final ivBase64 = await secureStorage.read(key: '${uniqueId}_iv');
    final encryptedTextBase64 =
        await secureStorage.read(key: '${uniqueId}_encrypted_text');

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
    var uuid = const Uuid();
    return uuid.v4();
  }
}

// import 'package:encrypt/encrypt.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:pointycastle/api.dart';
// import 'package:pointycastle/key_derivators/api.dart';
// import 'package:pointycastle/key_derivators/pbkdf2.dart';
// import 'dart:convert';
// import 'dart:math';
// import 'package:crypto/crypto.dart';
// import 'package:uuid/uuid.dart';

// class EncryptData {
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

//   Future<String> encryptString(String plainText) async {
//     final key = await getSecureKey();
//     final iv = IV.fromLength(12); // Generate a new IV for each encryption

//     final encrypter = Encrypter(ChaCha20Poly1305(key));
//     final encrypted = encrypter.encrypt(plainText, iv: iv);
//     final ivBase64 = base64Encode(iv.bytes); // Convert IV to base64

//     // Store IV and encrypted text together in secure storage
//     final uniqueId = generateUniqueId(); // You should implement this
//     await secureStorage.write(key: '${uniqueId}_iv', value: ivBase64);
//     await secureStorage.write(key: '${uniqueId}_encrypted_text', value: encrypted.base64);

//     return uniqueId; // Return the unique ID for reference
//   }

//   Future<String> decryptString(String uniqueId) async {
//     final key = await getSecureKey();

//     // Retrieve IV and encrypted text from secure storage using the unique ID
//     final ivBase64 = await secureStorage.read(key: '${uniqueId}_iv');
//     final encryptedTextBase64 =
//         await secureStorage.read(key: '${uniqueId}_encrypted_text');

//     if (ivBase64 == null || encryptedTextBase64 == null) {
//       return 'No encrypted data found';
//     }

//     final iv = IV.fromBase64(ivBase64); // Convert IV back from base64
//     final encrypted = Encrypted.fromBase64(encryptedTextBase64);

//     final decrypter = Encrypter(ChaCha20Poly1305(key));
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

//   Future<Key> generateSecureKey() async {
//     // 1. Use a cryptographically secure random number generator
//     final random = Random.secure();

//     // 2. Generate a sufficiently large random byte array (32 bytes for ChaCha20-Poly1305)
//     final salt = List<int>.generate(32, (_) => random.nextInt(256));

//     // 3. Use a key derivation function to generate a key from a passphrase or a master key
//     final passphrase = 'your passphrase here'; // You should use a strong passphrase
//     final params = PBKDF2Parameters(salt, 10000, 32); // You should use appropriate parameters
//     final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
//     derivator.init(params);
//     final keyBytes = derivator.process(utf8.encode(passphrase));

//     // 4. Create the Key object (replace with appropriate Key class)
//     return Key.fromBase64(base64Encode(keyBytes));
//   }

//   String generateUniqueId() {
//     var uuid = const Uuid();
//     return uuid.v4();
//   }
// }
