import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService(this._auth);

  final LocalAuthentication _auth;

  Future<bool> authenticate() async {
    final supported = await _auth.isDeviceSupported();
    if (!supported) return false;
    return _auth.authenticate(
      localizedReason: 'Unlock Apex CRM securely',
      options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
    );
  }
}
