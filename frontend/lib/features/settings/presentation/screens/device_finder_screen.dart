import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/features/device/data/device_link_state.dart';
import 'package:vexa/features/device/data/device_repository.dart';

class DeviceFinderScreen extends StatefulWidget {
  const DeviceFinderScreen({super.key});

  @override
  State<DeviceFinderScreen> createState() => _DeviceFinderScreenState();
}

class _DeviceFinderScreenState extends State<DeviceFinderScreen> {
  DeviceLinkState _link = const DeviceLinkState(hasServerPair: false);
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final remote = await DeviceRepository.fetchMyDevice();
      if (mounted) {
        setState(() => _link = DeviceLinkState.fromServer(remote));
      }
    } catch (_) {}
  }

  Future<void> _simulateFind() async {
    if (!_link.isLiveBlePaired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce Ayarlar → Cihaz → LilyGO\'ya bağlan.'),
        ),
      );
      return;
    }
    setState(() => _searching = true);
    for (var i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    if (!mounted) return;
    setState(() => _searching = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Simülasyon: cihaz bulundu. Gerçek BLE sinyali donanım ile gelecek.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text("VEXA'yı bul")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.radar_rounded,
              size: 72,
              color: _link.isLiveBlePaired ? AppColors.primary : muted,
            ),
            const SizedBox(height: 16),
            Text(
              _link.isLiveBlePaired
                  ? 'LilyGO eşlemesi aktif'
                  : 'Gerçek LilyGO eşlemesi yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bu ekran, kayıp VEXA cihazını titreşim veya BLE sinyali ile '
              'bulmak içindir. Donanım hazır olunca gerçek tarama burada çalışacak.',
              style: TextStyle(color: muted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _searching ? null : _simulateFind,
              icon: _searching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.vibration_rounded),
              label: Text(_searching ? 'Aranıyor…' : 'Cihazı bul (simülasyon)'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
