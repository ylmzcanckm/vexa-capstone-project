import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/device/data/device_repository.dart';
import 'package:vexa/features/mode/presentation/screens/mode_selection_screen.dart';
import 'package:vexa/features/onboarding/presentation/screens/avatar_selection_screen.dart';
import 'package:vexa/features/profile/presentation/screens/profile_creation_screen.dart';

/// Cihaz eşlemesi + BLE ile avatar aktarımı (LilyGO).
class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({
    super.key,
    required this.loginScreenBuilder,
  });

  final Widget Function() loginScreenBuilder;

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  final _ble = BleAvatarTransferService();
  bool _busy = false;
  String? _status;
  List<ScanResult> _scanResults = [];
  ScanResult? _selected;

  @override
  void dispose() {
    _ble.disconnect();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _status = 'Cihazlar aranıyor…';
      _scanResults = [];
      _selected = null;
    });
    try {
      final results = await _ble.scan();
      if (!mounted) return;
      setState(() {
        _scanResults = results;
        _status = results.isEmpty
            ? 'Cihaz bulunamadı. LilyGO açık ve yakında mı?'
            : '${results.length} cihaz bulundu';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connectAndSendAvatar() async {
    final pick = _selected;
    if (pick == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listeden bir cihaz seç.')),
      );
      return;
    }

    final profile = await UserProfileStore.load();
    if (profile == null || profile.avatarSeed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce avatar oluştur.')),
      );
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Bağlanılıyor…';
    });

    try {
      await _ble.connect(pick.device);
      if (!mounted) return;
      setState(() => _status = 'Avatar hazırlanıyor ve gönderiliyor…');

      await _ble.transferAvatarFromSeed(
        profile.avatarSeed,
        onProgress: (sent, total) {
          if (!mounted) return;
          setState(() => _status = 'Gönderiliyor: $sent / $total');
        },
      );

      final deviceCode = 'BLE-${pick.device.remoteId.str}';
      final deviceName = pick.device.platformName.isNotEmpty
          ? pick.device.platformName
          : 'VEXA LilyGO';
      await DeviceRepository.pairDevice(
        deviceCode: deviceCode,
        deviceName: deviceName,
      );

      await DeviceConnectionPreferences.setLinked(true);
      try {
        await UserRepository.syncFromServer();
      } catch (_) {}

      if (!mounted) return;
      await _finishOnboarding();
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      await _ble.disconnect();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _simulateConnect() async {
    setState(() => _busy = true);
    try {
      await DeviceRepository.pairDevice(
        deviceCode: 'VEXA-SIM-${DateTime.now().millisecondsSinceEpoch}',
        deviceName: 'VEXA Simulator',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cihaz kaydı: ${e.message}')),
      );
      return;
    }
    await DeviceConnectionPreferences.setLinked(true);
    try {
      await UserRepository.syncFromServer();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _busy = false);
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final profile = await UserProfileStore.load();
    final hasCore = profile != null &&
        profile.name.isNotEmpty &&
        profile.surname.isNotEmpty &&
        profile.birthDateIso.isNotEmpty;
    final hasAvatar = profile != null && profile.avatarSeed.isNotEmpty;
    if (hasCore && hasAvatar) {
      await OnboardingPreferences.setComplete(true);
    }
    if (!mounted) return;
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) {
          if (!hasCore) return const ProfileCreationScreen();
          if (!hasAvatar) return const AvatarSelectionScreen();
          return const ModeSelectionScreen();
        },
      ),
    );
  }

  void _backToLogin() {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(builder: (_) => widget.loginScreenBuilder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vexa = context.vexa;
    final bleOk = BleAvatarTransferService.isSupported;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: vexa.scaffold,
        appBar: AppBar(
          title: const Text('Cihaz bağlantısı'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'VEXA cihazını bağla',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  bleOk
                      ? 'Avatarın DiceBear PNG olarak indirilir, RGB565\'e çevrilir '
                          've BLE ile LilyGO ekranına yazılır.'
                      : 'Web sürümünde BLE yok; mobil uygulamada dene veya simülasyon kullan.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: vexa.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (_status != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _status!,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.accent),
                  ),
                ],
                if (bleOk) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _scan,
                    icon: const Icon(Icons.bluetooth_searching_rounded),
                    label: const Text('Bluetooth cihaz ara'),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _scanResults.isEmpty
                        ? Center(
                            child: Text(
                              'Arama sonrası cihazlar burada listelenir.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: vexa.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _scanResults.length,
                            itemBuilder: (context, index) {
                              final r = _scanResults[index];
                              final name = r.device.platformName.isNotEmpty
                                  ? r.device.platformName
                                  : r.device.remoteId.str;
                              final selected = _selected == r;
                              return Card(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : vexa.surface,
                                child: ListTile(
                                  leading: const Icon(Icons.bluetooth_rounded),
                                  title: Text(name),
                                  subtitle: Text('RSSI ${r.rssi} dBm'),
                                  trailing: selected
                                      ? const Icon(Icons.check_circle_rounded,
                                          color: AppColors.primary)
                                      : null,
                                  onTap: _busy
                                      ? null
                                      : () => setState(() => _selected = r),
                                ),
                              );
                            },
                          ),
                  ),
                  FilledButton(
                    onPressed: _busy || _selected == null
                        ? null
                        : _connectAndSendAvatar,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Bağlan ve avatarı gönder'),
                  ),
                ] else ...[
                  const Spacer(),
                  FilledButton(
                    onPressed: _busy ? null : _simulateConnect,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Simülasyon ile devam et'),
                  ),
                ],
                const SizedBox(height: 8),
                if (bleOk)
                  TextButton(
                    onPressed: _busy ? null : _simulateConnect,
                    child: const Text('Simülasyon (avatar göndermeden)'),
                  ),
                TextButton(
                  onPressed: _busy ? null : _backToLogin,
                  child: const Text('Giriş ekranına dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
