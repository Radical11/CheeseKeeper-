import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'dart:typed_data';

class EncryptionUtil {
  // Derive a 32-byte key from password using UTF8 encoding (for demo; use PBKDF2 in production)
  static Key deriveKey(String password) {
    final bytes = utf8.encode(password);
    // Pad or trim to 32 bytes
    final padded = List<int>.filled(32, 0)..setAll(0, bytes.take(32));
    return Key(Uint8List.fromList(padded));
  }

  static String encryptAES(String plainText, String password) {
    final key = deriveKey(password);
    final iv = IV.fromLength(16); // For demo, use a random IV in production!
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptAES(String encryptedText, String password) {
    final key = deriveKey(password);
    final iv = IV.fromLength(16); // Must match the IV used for encryption
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt64(encryptedText, iv: iv);
  }
}
