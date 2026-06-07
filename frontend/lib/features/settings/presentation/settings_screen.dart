import 'package:flutter/material.dart';
import 'package:vexa/features/settings/presentation/screens/about_vexa_screen.dart';
import 'package:vexa/features/settings/presentation/screens/accessibility_settings_screen.dart';
import 'package:vexa/features/settings/presentation/screens/account_settings_screen.dart';
import 'package:vexa/features/settings/presentation/screens/blocked_users_screen.dart';
import 'package:vexa/features/settings/presentation/screens/ble_device_settings_screen.dart';
import 'package:vexa/features/settings/presentation/screens/device_finder_screen.dart';
import 'package:vexa/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:vexa/features/settings/presentation/screens/privacy_security_settings_screen.dart';
import 'package:vexa/features/settings/presentation/screens/system_permissions_screen.dart';

/// Ayarlar menüsü (profil ve modlar ana ekrandan yönetilir).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Menü',
              style: textTheme.labelLarge?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.bluetooth_connected_rounded,
            title: 'Cihaz',
            subtitle: 'Bağlantı durumu ve donanım',
            onTap: () => _push(context, const BleDeviceSettingsScreen()),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirimler',
            subtitle: 'Push ve uygulama içi',
            onTap: () => _push(context, const NotificationSettingsScreen()),
          ),
          _MenuTile(
            icon: Icons.shield_outlined,
            title: 'Gizlilik / güvenlik',
            subtitle: 'Görünürlük ve KVKK',
            onTap: () => _push(context, const PrivacySecuritySettingsScreen()),
          ),
          _MenuTile(
            icon: Icons.accessibility_new_rounded,
            title: 'Erişilebilirlik',
            subtitle: 'Metin boyutu',
            onTap: () => _push(context, const AccessibilitySettingsScreen()),
          ),
          _MenuTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Hesap',
            subtitle: 'Karanlık mod, KVKK, çıkış',
            onTap: () => _push(context, const AccountSettingsScreen()),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            title: 'VEXA hakkında',
            subtitle: 'Sürüm ve bilgi',
            onTap: () => _push(context, const AboutVexaScreen()),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Araçlar',
              style: textTheme.labelLarge?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.radar_rounded,
            title: 'Device Finder',
            subtitle: "VEXA cihazını bul (simülasyon)",
            onTap: () => _push(context, const DeviceFinderScreen()),
          ),
          _MenuTile(
            icon: Icons.block_rounded,
            title: 'Engelle / gizle listesi',
            subtitle: 'Yerel engelleme listesi',
            onTap: () => _push(context, const BlockedUsersScreen()),
          ),
          _MenuTile(
            icon: Icons.app_settings_alt_outlined,
            title: 'Veri izinleri',
            subtitle: 'Bluetooth · Konum · Bildirim',
            onTap: () => _push(context, const SystemPermissionsScreen()),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
