import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/core/theme/theme_mode_provider.dart';
import 'package:vexa/features/auth/data/auth_repository.dart';
import 'package:vexa/features/auth/presentation/screens/login_screen.dart';

/// Hesap: karanlık mod, KVKK, çıkış (şifre değiştirme yok).
class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Hesap')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
            ),
            title: const Text('Karanlık mod'),
            subtitle: const Text('Uygulama genelinde koyu tema'),
            value: isDark,
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setDark(v),
          ),
          const Divider(height: 32),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade700),
            title: Text(
              'Hesabı sil',
              style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Kalıcı olarak sil; geri alınamaz (yakında).',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _soon(context),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('KVKK onay formu bilgileri'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _soon(context),
          ),
          const Divider(height: 32),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: muted),
            title: const Text('Çıkış yap'),
            onTap: () async {
              await AuthRepository.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil<void>(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Çıkış yapınca oturum kapanır; tekrar Google/Apple ile giriş yaparsın.',
            style: textTheme.bodySmall?.copyWith(
              color: muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
