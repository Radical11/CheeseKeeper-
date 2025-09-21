import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as enc;
// Import for BIP39 - uncomment when you add the bip39 package to pubspec.yaml
// import 'package:bip39/bip39.dart' as bip39;

class CryptoService {
  static enc.Key _deriveKeyFromPassword(String password, {String? salt}) {
    final String actualSalt = salt ?? 'defaultSecureLinkSalt_YOU_MUST_REPLACE_THIS_SALT_LOGIC';

    var passwordBytes = utf8.encode(password + actualSalt);
    var keyBytes = crypto.sha256.convert(passwordBytes).bytes;

    return enc.Key(Uint8List.fromList(keyBytes.sublist(0, 32)));
  }

  static Map<String, String> encryptAES(String plainText, String password) {
    final key = _deriveKeyFromPassword(password);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return {
      'ciphertext': encrypted.base64,
      'iv': iv.base64,
      // 'salt': base64Url.encode(generatedSalt), // If you generate and use a real salt
    };
  }

  static String? decryptAES(String encryptedBase64, String ivBase64, String password) {
    // final salt = base64Url.decode(saltBase64);
    // final key = _deriveKeyFromPassword(password, salt: salt); // Pass the retrieved salt
    try {
      final key = _deriveKeyFromPassword(password); // Uses default salt
      final iv = enc.IV.fromBase64(ivBase64);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt(enc.Encrypted.fromBase64(encryptedBase64), iv: iv);
      return decrypted;
    } catch (e) {
      print('AES Decryption Error: $e');
      return null;
    }
  }

  static String sha256Hash(String data) {
    final bytes = utf8.encode(data);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }

// --- Mnemonic operations ---
// Uncomment these and the bip39 import once the package is added.
// Ensure 'bip39: ^1.0.6' (or compatible) is in your pubspec.yaml

// static bool isValidMnemonic(String mnemonic) {
//   try {
//     return bip39.validateMnemonic(mnemonic);
//   } catch (e) {
//     print('Mnemonic validation error: $e');
//     return false;
//   }
// }

// static String generateMnemonic() {
//   return bip39.generateMnemonic(); // Default is 12 words (128 bits of entropy)
// }
}

// --- Example Usage (for testing this service in isolation) ---
// void main() {
//   // Test Hashing
//   const String dataToHash = 'This is my private key';
//   String hash = CryptoService.sha256Hash(dataToHash);
//   print('Original Data: $dataToHash');
//   print('SHA-256 Hash: $hash');
//   print('SHA-256 Hash of same data: ${CryptoService.sha256Hash(dataToHash)}');
//   print("SHA-256 Hash of different data: ${CryptoService.sha256Hash("Other data")}");
//
//   print('\n--- AES Encryption/Decryption Test ---');
//   const String mySecretMessage = 'MyTopSecretPrivateKeyMaterial';
//   const String myPassword = 'userLoginPassword123!';
//
//   // Encrypt
//   Map<String, String> encryptionResult = CryptoService.encryptAES(mySecretMessage, myPassword);
//   String encryptedText = encryptionResult['ciphertext']!;
//   String iv = encryptionResult['iv']!;
//
//   print('Original Message: $mySecretMessage');
//   print('Encrypted (Base64): $encryptedText');
//   print('IV (Base64): $iv');
//
//   // Decrypt with correct password
//   String? decryptedMessage = CryptoService.decryptAES(encryptedText, iv, myPassword);
//   print('Decrypted Message: $decryptedMessage');
//
//   // Test decryption with wrong password
//   String? wrongDecryption = CryptoService.decryptAES(encryptedText, iv, 'wrongPassword!');
//   print('Decryption with wrong password: $wrongDecryption');

  // --- Mnemonic Test (Uncomment when bip39 is added and methods are uncommented) ---
  // print("\n--- Mnemonic Test ---");
  // String newMnemonic = CryptoService.generateMnemonic();
  // print("Generated Mnemonic: $newMnemonic");
  // print("Is '$newMnemonic' valid? ${CryptoService.isValidMnemonic(newMnemonic)}");
  //
  // const String testValidMnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  // print("Is '$testValidMnemonic' valid? ${CryptoService.isValidMnemonic(testValidMnemonic)}"); // Should be true
  //
  // const String testInvalidMnemonic = 'apple banana cherry';
  // print("Is '$testInvalidMnemonic' valid? ${CryptoService.isValidMnemonic(testInvalidMnemonic)}"); // Should be false
