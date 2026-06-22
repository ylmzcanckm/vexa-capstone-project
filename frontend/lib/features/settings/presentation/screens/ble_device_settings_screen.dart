import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vexa/core/storage/bound_lilygo_store.dart';
import 'package:vexa/core/storage/device_settings_preferences.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/features/auth/presentation/screens/login_screen.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/device/data/device_link_state.dart';
import 'package:vexa/features/device/data/device_repository.dart';
import 'package:vexa/features/device/presentation/screens/device_connection_screen.dart';

/// BLE / cihaz ayarları — `def3` donanım senkronu.
class BleDeviceSettingsScreen extends StatefulWidget {
  const BleDeviceSettingsScreen({super.key});

  @override
  State<BleDeviceSettingsScreen> createState() => _BleDeviceSettingsScreenState();
}

class _BleDeviceSettingsScreenState extends State<BleDeviceSettingsScreen> {
  final _ble = BleAvatarTransferService();
  DeviceLinkState _link = const DeviceLinkState(hasServerPair: false);
  DeviceSettingsValues _settings = const DeviceSettingsValues();
  bool _loading = true;
  bool _syncing = false;
  String? _syncStatus;
  Timer? _brightnessDebounce;

  String? _boundBleName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _brightnessDebounce?.cancel();
    _ble.disconnect();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final remote = await DeviceRepository.fetchMyDevice();
      final link = DeviceLinkState.fromServer(remote);
      final prefs = await DeviceSettingsPreferences.load();
      try {
        final me = await UserRepository.fetchMe();
        await BoundLilyGoStore.setActiveUserId(me.id);
      } catch (_) {}
      await BoundLilyGoStore.syncFromServerDeviceCode(link.deviceCode);
      final bound = await BoundLilyGoStore.load();
      if (!mounted) return;
      setState(() {
        _link = link;
        _boundBleName = bound ?? link.deviceCode;
        _settings = prefs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final bound = await BoundLilyGoStore.load();
      setState(() {
        _boundBleName = bound;
        _loading = false;
      });
    }
  }

  Future<void> _unpairDevice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eşleşmeyi kaldır'),
        content: const Text(
          'LilyGO eşleşmesi silinecek. Avatar ve ayarlar artık otomatik '
          'bu cihaza gitmez. Yeniden eşleşmek için cihaz seçmen gerekir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await BoundLilyGoStore.clear();
      await DeviceRepository.unpairDevice();
      await DeviceConnectionPreferences.setDeviceStepComplete(false);
    } catch (_) {}
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('LilyGO eşleşmesi kaldırıldı.')),
    );
  }

  Future<void> _openDeviceConnection() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DeviceConnectionScreen(
          loginScreenBuilder: () => const LoginScreen(),
          reconnectOnly: true,
        ),
      ),
    );
    if (ok == true) await _load();
  }

  Future<void> _applySettings(DeviceSettingsValues next) async {
    setState(() => _settings = next);
    await DeviceSettingsPreferences.save(next);

    if (!_link.isLiveBlePaired && !await BoundLilyGoStore.hasBinding()) {
      return;
    }

    setState(() {
      _syncing = true;
      _syncStatus = 'Cihaza gönderiliyor…';
    });

    try {
      final err = await _ble.scanConnectAndSyncSettings(next);
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _syncStatus = err == null ? 'Cihaza uygulandı' : 'Gönderilemedi: $err';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _syncStatus = 'Hata: $e';
      });
    }
  }

  void _onBrightnessChanged(double value) {
    final next = _settings.copyWith(brightness: value);
    setState(() => _settings = next);
    _brightnessDebounce?.cancel();
    _brightnessDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_applySettings(next));
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final surface = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).dividerColor;
    final hasBinding =
        _boundBleName != null && _boundBleName!.trim().isNotEmpty;
    final liveBle = hasBinding || _link.isLiveBlePaired;
    final canSync = hasBinding && BleAvatarTransferService.isSupported;

    return Scaffold(
      appBar: AppBar(title: const Text('Cihaz ayarları')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _StatusCard(
            loading: _loading,
            liveBle: liveBle,
            deviceName: _boundBleName ?? _link.deviceName ?? _link.deviceCode,
            hasPair: hasBinding || _link.hasServerPair,
            muted: muted,
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading || _syncing ? null : _openDeviceConnection,
            icon: Icon(
              hasBinding
                  ? Icons.swap_horiz_rounded
                  : Icons.bluetooth_searching_rounded,
            ),
            label: Text(hasBinding ? 'Cihazı değiştir' : 'LilyGO\'ya bağlan'),
          ),
          if (hasBinding) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loading || _syncing ? null : _unpairDevice,
              icon: const Icon(Icons.link_off_rounded),
              label: const Text('Eşleşmeyi kaldır'),
            ),
          ],
          if (liveBle) ...[
            const SizedBox(height: 8),
            Text(
              'Avatar değiştirdiğinde cihaza otomatik gönderilir.',
              style: textTheme.bodySmall?.copyWith(color: muted, height: 1.35),
            ),
          ],
          if (_syncing || _syncStatus != null) ...[
            const SizedBox(height: 8),
            Text(
              _syncing ? 'Cihaza gönderiliyor…' : _syncStatus!,
              style: textTheme.bodySmall?.copyWith(
                color: _syncing ? AppColors.accent : muted,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionTitle(text: 'Titreşim', textTheme: textTheme),
          if (!canSync)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'Tercih kaydedilir; cihaza yazmak için LilyGO bağlantısı gerekir.',
                style: textTheme.bodySmall?.copyWith(color: muted, height: 1.3),
              ),
            ),
          const SizedBox(height: 8),
          _ChoiceRow(
            labels: const ['Güçlü', 'Hafif', 'Kapalı'],
            selectedIndex: _settings.vibrationIndex,
            onSelected: _loading || _syncing
                ? null
                : (i) => unawaited(_applySettings(_settings.copyWith(vibrationIndex: i))),
            textTheme: textTheme,
            surface: surface,
            border: border,
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Parlaklık', textTheme: textTheme),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Otomatik'),
            subtitle: Text(
              'Işık sensörü yok; tercih kaydedilir.',
              style: textTheme.bodySmall?.copyWith(color: muted),
            ),
            value: _settings.autoBrightness,
            onChanged: _loading || _syncing
                ? null
                : (v) => unawaited(_applySettings(_settings.copyWith(autoBrightness: v))),
          ),
          Slider(
            value: _settings.brightness,
            onChanged: _loading || _syncing || _settings.autoBrightness
                ? null
                : _onBrightnessChanged,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '%${_settings.brightnessPercent}',
              style: textTheme.labelMedium?.copyWith(color: muted),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(text: 'Ekran kapanma', textTheme: textTheme),
          const SizedBox(height: 8),
          _ChoiceRow(
            labels: const ['10 sn', '30 sn', 'Sürekli'],
            selectedIndex: _settings.screenTimeoutIndex,
            onSelected: _loading || _syncing
                ? null
                : (i) => unawaited(_applySettings(_settings.copyWith(screenTimeoutIndex: i))),
            textTheme: textTheme,
            surface: surface,
            border: border,
          ),
          if (!BleAvatarTransferService.isSupported) ...[
            const SizedBox(height: 16),
            Text(
              'Donanım ayarları mobil uygulamada kullanılabilir.',
              style: textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.loading,
    required this.liveBle,
    required this.deviceName,
    required this.hasPair,
    required this.muted,
    required this.textTheme,
  });

  final bool loading;
  final bool liveBle;
  final String? deviceName;
  final bool hasPair;
  final Color muted;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final title = loading
        ? 'Yükleniyor…'
        : liveBle
            ? deviceName ?? 'LilyGO'
            : hasPair
                ? deviceName ?? 'Kayıtlı cihaz'
                : 'Bağlı değil';

    final subtitle = loading
        ? ''
        : liveBle
            ? 'Bağlantı aktif'
            : hasPair
                ? 'LilyGO ile yeniden bağlan'
                : 'Cihazını eşle';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              liveBle ? Icons.watch_rounded : Icons.bluetooth_disabled_rounded,
              color: liveBle ? AppColors.primary : muted,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: textTheme.bodySmall?.copyWith(color: muted)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.textTheme});

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    required this.textTheme,
    required this.surface,
    required this.border,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final TextTheme textTheme;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(labels.length, (i) {
        final selected = i == selectedIndex;
        return ChoiceChip(
          label: Text(labels[i], style: textTheme.labelLarge),
          selected: selected,
          onSelected: onSelected == null ? null : (_) => onSelected!(i),
          side: BorderSide(color: border),
          backgroundColor: surface,
        );
      }),
    );
  }
}
