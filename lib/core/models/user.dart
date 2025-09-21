class User {
  final String publicKey;
  final String? encryptedPrivateKey;
  final String? mnemonic;

  User({
    required this.publicKey,
    this.encryptedPrivateKey,
    this.mnemonic,
  });

  // Example: Convert to Map for storage
  Map<String, dynamic> toMap() => {
        'publicKey': publicKey,
        'encryptedPrivateKey': encryptedPrivateKey,
        'mnemonic': mnemonic,
      };

  // Example: Create User from Map
  factory User.fromMap(Map<String, dynamic> map) => User(
        publicKey: map['publicKey'],
        encryptedPrivateKey: map['encryptedPrivateKey'],
        mnemonic: map['mnemonic'],
      );
}