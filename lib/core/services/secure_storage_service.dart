import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Keychain / Keystore-backed storage for tokens used by the optional REST
/// backend. Firebase Auth manages its own session securely and does not use
/// this.
class SecureStorageService extends GetxService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;
  static const _apiToken = 'api_access_token';

  Future<String?> readApiToken() => _storage.read(key: _apiToken);
  Future<void> writeApiToken(String token) => _storage.write(key: _apiToken, value: token);
  Future<void> clear() => _storage.deleteAll();
}
