import 'package:flutter/material.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/navigation/app_router.dart';
import 'package:vexa/features/auth/data/auth_repository.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/features/device/data/device_repository.dart';
import 'package:vexa/features/auth/presentation/screens/login_screen.dart';

/// Token kontrolü → sunucudan profil çek → uygun ekrana yönlendir.
class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  Widget? _child;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final hasToken = await AuthRepository.hasSession();
      if (!hasToken) {
        _setChild(const LoginScreen());
        return;
      }

      await UserRepository.syncFromServer();
      final paired = await DeviceRepository.fetchMyDevice();
      if (paired != null) {
        await DeviceConnectionPreferences.setLinked(true);
      }
      if (!mounted) return;
      final next = await AppRouter.homeForAuthenticatedUser();
      if (!mounted) return;
      _setChild(next);
    } on ApiException catch (e) {
      await AuthRepository.logout();
      if (!mounted) return;
      if (e.statusCode == 401) {
        _setChild(const LoginScreen());
      } else {
        setState(() => _error = e.message);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Sunucuya bağlanılamadı. İnternet bağlantını kontrol et veya biraz sonra tekrar dene.';
      });
    }
  }

  void _setChild(Widget child) {
    if (!mounted) return;
    setState(() {
      _child = child;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _child = null;
                      _error = null;
                    });
                    _bootstrap();
                  },
                  child: const Text('Tekrar dene'),
                ),
                TextButton(
                  onPressed: () async {
                    await AuthRepository.logout();
                    if (!mounted) return;
                    _setChild(const LoginScreen());
                  },
                  child: const Text('Giriş ekranına dön'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _child ??
        const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
  }
}
