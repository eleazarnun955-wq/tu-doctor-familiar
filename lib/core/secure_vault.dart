import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cifrado local autenticado AES-256-GCM para datos guardados por la app.
/// La clave se conserva en el almacenamiento seguro del sistema operativo.
class SecureVault {
  SecureVault._();
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'tdf_vault_key_v1';
  static final _algorithm = AesGcm.with256bits();

  static Future<SecretKey> _key() async {
    final saved = await _storage.read(key: _keyName);
    if (saved != null) return SecretKey(base64Decode(saved));
    final generated = await _algorithm.newSecretKey();
    final bytes = await generated.extractBytes();
    await _storage.write(key: _keyName, value: base64Encode(bytes));
    return SecretKey(bytes);
  }

  static Future<String?> read(String name) async {
    final packed = await _storage.read(key: 'vault_$name');
    if (packed == null) return null;
    try {
      final data = jsonDecode(packed) as Map<String, dynamic>;
      final box = SecretBox(
        base64Decode(data['cipherText'] as String),
        nonce: base64Decode(data['nonce'] as String),
        mac: Mac(base64Decode(data['mac'] as String)),
      );
      final clear = await _algorithm.decrypt(box, secretKey: await _key());
      return utf8.decode(clear);
    } catch (_) {
      rethrow;
    }
  }

  static Future<void> write(String name, String value) async {
    final box = await _algorithm.encrypt(
      utf8.encode(value),
      secretKey: await _key(),
    );
    final packed = jsonEncode({
      'nonce': base64Encode(box.nonce),
      'cipherText': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
    await _storage.write(key: 'vault_$name', value: packed);
  }

  static Future<void> delete(String name) => _storage.delete(key: 'vault_$name');
}
