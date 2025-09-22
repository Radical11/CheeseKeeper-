import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as enc;

class CryptoService {
  static enc.Key _deriveKeyFromPassword(String password, {String? salt}) {
    final String actualSalt = salt ?? 'CheeseKeeper_HardwareWallet_Salt_2024';
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
    };
  }

  static String? decryptAES(String encryptedBase64, String ivBase64, String password) {
    try {
      final key = _deriveKeyFromPassword(password);
      final iv = enc.IV.fromBase64(ivBase64);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt(enc.Encrypted.fromBase64(encryptedBase64), iv: iv);
      return decrypted;
    } catch (e) {
      return null;
    }
  }

  static String sha256Hash(String data) {
    final bytes = utf8.encode(data);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }
}