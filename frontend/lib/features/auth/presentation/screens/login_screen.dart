import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/api/app_preferences_sync.dart';
import 'package:vexa/core/navigation/app_router.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/auth/data/auth_repository.dart';
import 'package:vexa/features/auth/data/user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;
  bool _backendReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_warmUp());
  }

  Future<void> _warmUp() async {
    await AuthRepository.warmUpBackend();
    if (mounted) setState(() => _backendReady = true);
  }

  String _friendlyError(Object e) {
    if (e is TimeoutException) {
      return 'Sunucu yanıt vermedi. İnternet bağlantını kontrol edip '
          'birkaç saniye sonra tekrar dene (Render uyanması biraz sürebilir).';
    }
    if (e is ApiException) return e.message;
    return 'Giriş başarısız: $e';
  }

  Future<void> _signIn(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (!_backendReady) {
        await AuthRepository.warmUpBackend();
      }
      await action();
      if (!mounted) return;
      await UserRepository.syncFromServer();
      if (!mounted) return;
      await AppPreferencesSync.refreshProvidersFromLocalStorage(
        ProviderScope.containerOf(context),
      );
      if (!mounted) return;
      final next = await AppRouter.homeForAuthenticatedUser();
      if (!mounted) return;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => next,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
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
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
                    if (!_backendReady) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: vexa.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Sunucuya bağlanılıyor…',
                            style: TextStyle(
                              color: vexa.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(flex: 3),
                    _LoginButton(
                      label: 'Google ile Devam Et',
                      icon: FontAwesomeIcons.google,
                      backgroundColor: AppColors.primary,
                      onPressed: _busy
                          ? null
                          : () => _signIn(AuthRepository.loginWithGoogle),
                    ),
                    const SizedBox(height: 12),
                    _LoginButton(
                      label: 'Apple ile Devam Et',
                      icon: FontAwesomeIcons.apple,
                      backgroundColor: AppColors.accent,
                      onPressed: _busy
                          ? null
                          : () => _signIn(AuthRepository.loginWithApple),
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
              if (_busy)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Giriş yapılıyor…',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white70,
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
