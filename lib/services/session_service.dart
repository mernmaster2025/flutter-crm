import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';
import '../domain/entities/crm_models.dart';

class SessionService {
  SessionService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveSession(AppUser user) async {
    await _storage.write(key: AppConstants.secureTokenKey, value: 'demo-token-${user.id}');
    await _storage.write(key: AppConstants.secureUserKey, value: jsonEncode(user.toJson()));
  }

  Future<AppUser?> restoreUser() async {
    final token = await _storage.read(key: AppConstants.secureTokenKey);
    final rawUser = await _storage.read(key: AppConstants.secureUserKey);
    if (token == null || rawUser == null) return null;
    return AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    await _storage.delete(key: AppConstants.secureTokenKey);
    await _storage.delete(key: AppConstants.secureUserKey);
  }
}
