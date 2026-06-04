import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../widgets/premium_scaffold.dart';
import '../providers/app_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, register, forgotPassword, otp }

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Maya Chen');
  final _emailController = TextEditingController(text: 'maya@apexcrm.dev');
  final _passwordController = TextEditingController(text: 'password123');
  final _otpController = TextEditingController(text: '248610');
  bool _rememberMe = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final mode = widget.mode;
    return PremiumScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BrandHeader(mode: mode),
                    const SizedBox(height: AppSpacing.xl),
                    if (mode == AuthMode.register) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full name'),
                        validator: (value) => Validators.required(value, field: 'Name'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (mode != AuthMode.otp) ...[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Work email'),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (mode == AuthMode.login || mode == AuthMode.register) ...[
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (mode == AuthMode.login)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Remember me on this device'),
                        value: _rememberMe,
                        onChanged: (value) => setState(() => _rememberMe = value ?? true),
                      ),
                    if (mode == AuthMode.otp)
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '6-digit verification code'),
                        validator: (value) => value?.length == 6 ? null : 'Enter the 6-digit code',
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_primaryLabel(mode)),
                    ),
                    if (mode == AuthMode.login) ...[
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: authState.isLoading ? null : () => ref.read(authRepositoryProvider).biometricLogin(),
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: const Text('Use biometric login'),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _AuthLinks(mode: mode),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _primaryLabel(AuthMode mode) {
    return switch (mode) {
      AuthMode.login => 'Sign in',
      AuthMode.register => 'Create account',
      AuthMode.forgotPassword => 'Send reset link',
      AuthMode.otp => 'Verify account',
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider.notifier);
    switch (widget.mode) {
      case AuthMode.login:
        await controller.login(_emailController.text, _passwordController.text, _rememberMe);
        if (mounted) context.go('/dashboard');
        break;
      case AuthMode.register:
        await controller.register(_nameController.text, _emailController.text, _passwordController.text);
        if (mounted) context.go('/dashboard');
        break;
      case AuthMode.forgotPassword:
        await ref.read(authRepositoryProvider).forgotPassword(_emailController.text);
        if (mounted) context.go('/otp');
        break;
      case AuthMode.otp:
        final verified = await ref.read(authRepositoryProvider).verifyOtp(_otpController.text);
        if (verified && mounted) context.go('/login');
        break;
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    final title = switch (mode) {
      AuthMode.login => 'Welcome back',
      AuthMode.register => 'Start your workspace',
      AuthMode.forgotPassword => 'Recover access',
      AuthMode.otp => 'Verify your account',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.hub_rounded, color: Theme.of(context).colorScheme.primary, size: 30),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(AppConstants.appName, style: Theme.of(context).textTheme.labelLarge),
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: AppSpacing.xs),
        Text(AppConstants.appTagline, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _AuthLinks extends StatelessWidget {
  const _AuthLinks({required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      children: [
        TextButton(onPressed: () => context.go('/login'), child: const Text('Login')),
        TextButton(onPressed: () => context.go('/register'), child: const Text('Register')),
        TextButton(onPressed: () => context.go('/forgot-password'), child: const Text('Forgot password')),
      ],
    );
  }
}
