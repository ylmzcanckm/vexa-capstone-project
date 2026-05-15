import 'package:flutter/material.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/features/auth/presentation/screens/login_screen.dart';
import 'package:vexa/features/mode/presentation/screens/mode_selection_screen.dart';

/// İlk açılışta kayıt durumunu okuyup doğrudan login veya ana ekrana yönlendirir.
class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  Widget? _child;

  @override
  void initState() {
    super.initState();
    _resolveHome();
  }

  Future<void> _resolveHome() async {
    final done = await OnboardingPreferences.isComplete();
    if (!mounted) return;
    setState(() {
      _child = done ? const ModeSelectionScreen() : const LoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _child ??
        const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
  }
}
