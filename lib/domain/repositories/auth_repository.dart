import '../entities/crm_models.dart';

abstract interface class AuthRepository {
  Future<AppUser?> restoreSession();
  Future<AppUser> login({
    required String email,
    required String password,
    required bool rememberMe,
  });
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> forgotPassword(String email);
  Future<bool> verifyOtp(String otp);
  Future<bool> biometricLogin();
  Future<void> logout();
}
