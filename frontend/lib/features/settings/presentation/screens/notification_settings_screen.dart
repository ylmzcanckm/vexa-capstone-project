import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/features/settings/providers/settings_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (kIsWeb)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Web sürümünde push bildirimleri henüz yok; tercihlerin kaydedilir '
                  've mobil uygulamada kullanılır.',
                  style: TextStyle(color: muted, height: 1.4, fontSize: 13),
                ),
              ),
            ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Push bildirimleri'),
            value: settings.pushEnabled,
            onChanged: notifier.setPush,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.chat_bubble_outline_rounded),
            title: const Text('Uygulama içi bildirimler'),
            value: settings.inAppEnabled,
            onChanged: notifier.setInApp,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.favorite_border_rounded),
            title: const Text('Eşleşme uyarıları'),
            value: settings.matchAlertsEnabled,
            onChanged: notifier.setMatchAlerts,
          ),
        ],
      ),
    );
  }
}
