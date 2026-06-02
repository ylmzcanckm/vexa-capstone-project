import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/navigation/app_router.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/auth/data/auth_repository.dart';
import 'package:vexa/features/auth/data/user_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signIn(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      await UserRepository.syncFromServer();
      if (!context.mounted) return;
      final next = await AppRouter.homeForAuthenticatedUser();
      if (!context.mounted) return;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => next,
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş başarısız: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vexa = context.vexa;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: vexa.loginGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const Center(child: _BrandWordmark()),
                const SizedBox(height: 32),
                Text(
                  'Hoş Geldiniz',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hesabınla devam et.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                const Spacer(flex: 3),
                _LoginButton(
                  label: 'Google ile Devam Et',
                  icon: FontAwesomeIcons.google,
                  backgroundColor: AppColors.primary,
                  onPressed: () => _signIn(
                    context,
                    AuthRepository.loginWithGoogle,
                  ),
                ),
                const SizedBox(height: 12),
                _LoginButton(
                  label: 'Apple ile Devam Et',
                  icon: FontAwesomeIcons.apple,
                  backgroundColor: AppColors.accent,
                  onPressed: () => _signIn(
                    context,
                    AuthRepository.loginWithApple,
                  ),
                ),
                const Spacer(),
                Text(
                  'Devam ederek Kullanım Koşulları\'nı kabul etmiş olursunuz.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppColors.brandGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: const Text(
        'VEXA',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      icon: FaIcon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }
}
