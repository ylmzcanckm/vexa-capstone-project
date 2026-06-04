import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/features/settings/presentation/screens/kvkk_consent_screen.dart';
import 'package:vexa/features/settings/providers/settings_providers.dart';

class PrivacySecuritySettingsScreen extends ConsumerWidget {
  const PrivacySecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(privacySettingsProvider);
    final notifier = ref.read(privacySettingsProvider.notifier);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik / güvenlik')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.radar_rounded),
            title: const Text('Keşifte görün'),
            subtitle: Text(
              'Kapalıyken eşleşme adaylarında görünmezsin (yerel tercih; '
              'sunucu senkronu yakında).',
              style: TextStyle(fontSize: 12, color: muted),
            ),
            value: settings.discoverable,
            onChanged: notifier.setDiscoverable,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alternate_email_rounded),
            title: const Text('Profilde e-posta göster'),
            subtitle: const Text('Diğer kullanıcılara e-posta adresin'),
            value: settings.showEmailOnProfile,
            onChanged: notifier.setShowEmail,
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('KVKK ve aydınlatma metni'),
            subtitle: Text(
              settings.kvkkAcceptedAtIso == null
                  ? 'Henüz onaylanmadı'
                  : 'Onay: ${_formatDate(settings.kvkkAcceptedAtIso!)}',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const KvkkConsentScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
  }
}
