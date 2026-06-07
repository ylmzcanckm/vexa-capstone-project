import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
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
    this.reconnectOnly = false,
  });

  final Widget Function() loginScreenBuilder;

  /// Ayarlardan açıldıysa onboarding akışını atlama — sadece geri dön.
  final bool reconnectOnly;

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
  void initState() {
    super.initState();
    if (BleAvatarTransferService.isSupported) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
    }
  }

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
      final best = BleAvatarTransferService.pickBestVexaDevice(results);
      if (!mounted) return;
      setState(() {
        _scanResults = results;
        _selected = best;
        _status = results.isEmpty
            ? 'Cihaz bulunamadı. LilyGO açık ve yakında mı?'
            : best != null
                ? 'Hazır: ${BleAvatarTransferService.displayName(best.device)}'
                : '${results.length} cihaz — birini seç';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = _friendlyBleError('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _friendlyBleError(String raw) {
    if (raw.contains('bluetooth must be turned on') ||
        raw.contains('CBManagerState')) {
      return 'Bluetooth kapalı. Ayarlardan aç ve tekrar dene.';
    }
    if (raw.contains('izni')) return raw;
    return raw;
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
      setState(() => _status = 'Avatar gönderiliyor…');

      await _ble.transferAvatarFromSeed(
        profile.avatarSeed,
        onProgress: (sent, total) {
          if (!mounted) return;
          setState(() => _status = 'Gönderiliyor: $sent / $total');
        },
      );

      if (!mounted) return;
      setState(() => _status = 'Saat ayarlanıyor…');
      final clockErr = await _ble.syncDeviceClock();
      if (clockErr != null) {
        throw Exception('Saat gönderilemedi: $clockErr');
      }
      await Future<void>.delayed(const Duration(seconds: 3));

      final deviceCode = BleAvatarTransferService.pairCodeFor(pick.device);
      final deviceName = BleAvatarTransferService.displayName(pick.device);
      await DeviceRepository.pairDevice(
        deviceCode: deviceCode,
        deviceName: deviceName,
      );

      await DeviceConnectionPreferences.setDeviceStepComplete(true);
      try {
        await UserRepository.syncFromServer();
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cihaz bağlandı.')),
      );
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

  Future<void> _finishOnboarding() async {
    if (widget.reconnectOnly) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }

    if (await OnboardingPreferences.isComplete()) {
      if (!mounted) return;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(builder: (_) => const ModeSelectionScreen()),
      );
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vexa = context.vexa;
    final bleOk = BleAvatarTransferService.isSupported;

    return PopScope(
      canPop: widget.reconnectOnly,
      child: Scaffold(
        backgroundColor: vexa.scaffold,
        appBar: AppBar(
          title: const Text('Cihaz bağlantısı'),
          automaticallyImplyLeading: widget.reconnectOnly,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'LilyGO\'nu bağla',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  bleOk
                      ? 'Cihazını aç, telefonun yakınında tut ve bağlan.'
                      : 'BLE yalnızca mobil uygulamada çalışır.',
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
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _scan,
                    icon: const Icon(Icons.bluetooth_searching_rounded),
                    label: Text(_busy ? 'Aranıyor…' : 'Tekrar ara'),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _scanResults.isEmpty
                        ? Center(
                            child: Text(
                              _busy ? 'Cihaz aranıyor…' : 'Henüz cihaz bulunamadı',
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
                                margin: const EdgeInsets.only(bottom: 8),
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : vexa.surface,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.watch_rounded,
                                    color: selected ? AppColors.primary : vexa.textSecondary,
                                  ),
                                  title: Text(name),
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
                        : const Text('Bağlan'),
                  ),
                ] else ...[
                  const Spacer(),
                  Text(
                    'Bu sürümde cihaz bağlantısı desteklenmiyor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: vexa.textSecondary),
                  ),
                  const Spacer(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
