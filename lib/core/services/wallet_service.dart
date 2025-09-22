import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:web3dart/web3dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static const _storagePrivKeyHex = 'ck_priv_key_hex'; // only used temporarily until encrypted

  static String bytesToHex(Uint8List bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static String sha256Hex(Uint8List data) => crypto.sha256.convert(data).toString();

  // Generate a 32-byte random private key (for demo purposes)
  static Future<String> generatePrivateKeyHex() async {
    final rnd = Random.secure();
    final bytes = Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));
    return bytesToHex(bytes);
  }

  // Derive Ethereum address (0x...) from private key hex
  static Future<String> deriveAddressHex(String privKeyHex) async {
    final creds = EthPrivateKey.fromHex(privKeyHex);
    final addr = await creds.extractAddress();
    return addr.hexEip55;
  }

  // Temporarily persist plaintext private key (hex) until password step encrypts it.
  static Future<void> cachePlainPrivateKey(String privKeyHex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storagePrivKeyHex, privKeyHex);
  }

  static Future<String?> loadCachedPlainPrivateKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storagePrivKeyHex);
  }

  static Future<void> clearCachedPlainPrivateKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storagePrivKeyHex);
  }
}
