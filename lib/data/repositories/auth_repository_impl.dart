import '../../domain/entities/crm_models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../services/biometric_service.dart';
import '../../services/session_service.dart';
import '../sample/sample_crm_data.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SessionService sessionService,
    required BiometricService biometricService,
  })  : _sessionService = sessionService,
        _biometricService = biometricService;

  final SessionService _sessionService;
  final BiometricService _biometricService;

  @override
  Future<AppUser?> restoreSession() => _sessionService.restoreUser();

  @override
  Future<AppUser> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final user = SampleCrmData.user;
    if (rememberMe) await _sessionService.saveSession(user);
    return user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    final user = AppUser(
      id: 'u_new',
      name: name,
      email: email,
      role: UserRole.salesRep,
      avatarUrl: '',
      team: 'Sales',
    );
    await _sessionService.saveSession(user);
    return user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  Future<bool> verifyOtp(String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return otp.length == 6;
  }

  @override
  Future<bool> biometricLogin() => _biometricService.authenticate();

  @override
  Future<void> logout() => _sessionService.clear();
}
