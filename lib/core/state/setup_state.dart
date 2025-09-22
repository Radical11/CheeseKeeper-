import 'package:flutter/foundation.dart';

class SetupState extends ChangeNotifier {
  String? publicKey;
  String? privateKeyPlain;
  String? password;
  String? encryptedPrivateKey; // stored locally after password step

  void setPublicKey(String value) {
    publicKey = value;
    notifyListeners();
  }

  void setPrivateKey(String value) {
    privateKeyPlain = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setEncryptedPrivateKey(String value) {
    encryptedPrivateKey = value;
    notifyListeners();
  }

  void clearEphemeral() {
    privateKeyPlain = null;
    password = null;
    notifyListeners();
  }
}
