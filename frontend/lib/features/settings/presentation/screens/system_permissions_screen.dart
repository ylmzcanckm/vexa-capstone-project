import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';

class SystemPermissionsScreen extends StatelessWidget {
  const SystemPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final platformHint = _platformHint();

    return Scaffold(
      appBar: AppBar(title: const Text('Sistem izinleri')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                platformHint,
                style: TextStyle(color: muted, height: 1.45, fontSize: 13),
              ),
            ),
          ),
          _PermissionTile(
            icon: Icons.bluetooth_rounded,
            title: 'Bluetooth',
            description:
                'VEXA cihazını taramak ve eşlemek için gerekli. Donanım hazır '
                'olunca uygulama içinden istenecek.',
          ),
          _PermissionTile(
            icon: Icons.location_on_outlined,
            title: 'Konum',
            description:
                'Yakındaki cihaz taraması (BLE) için bazı platformlarda '
                'gerekir; eşleşme için zorunlu değildir.',
          ),
          _PermissionTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirim',
            description:
                'Eşleşme ve sistem uyarıları için. Ayarlar → Bildirimler '
                'menüsünden tercihlerini yönetebilirsin.',
          ),
        ],
      ),
    );
  }

  String _platformHint() {
    if (kIsWeb) {
      return 'Web sürümünde Bluetooth ve bildirim izinleri tarayıcı ve '
          'işletim sistemi ayarlarından yönetilir.';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS =>
        'iOS: Ayarlar → VEXA uygulamasından izinleri güncelleyebilirsin.',
      TargetPlatform.android =>
        'Android: Ayarlar → Uygulamalar → VEXA → İzinler.',
      _ => 'İzinleri cihazının uygulama ayarlarından yönet.',
    };
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        description,
        style: TextStyle(fontSize: 13, color: muted, height: 1.35),
      ),
    );
  }
}
