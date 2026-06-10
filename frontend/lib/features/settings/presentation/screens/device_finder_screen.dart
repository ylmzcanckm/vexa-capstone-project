import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/features/device/data/device_link_state.dart';
import 'package:vexa/features/device/data/device_repository.dart';
import 'package:vexa/features/finder/data/vexa_finder_service.dart';

/// VEXA Finder — yakınlık eşleşme uyarısı (mavi-mor tam ekran + titreşim).
class DeviceFinderScreen extends StatefulWidget {
  const DeviceFinderScreen({super.key});

  @override
  State<DeviceFinderScreen> createState() => _DeviceFinderScreenState();
}

class _DeviceFinderScreenState extends State<DeviceFinderScreen> {
  DeviceLinkState _link = const DeviceLinkState(hasServerPair: false);

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

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('VEXA Finder')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.brandGradient,
              ),
              child: const Center(
                child: Icon(
                  Icons.sensors_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Yakınlık eşleşmesi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Uyumlu biri ~15 m yakına gelince LilyGO titreşir ve telefonda '
              'mavi-mor tam ekran uyarı açılır. Titreşim motoru firmware ile '
              'aktif olunca otomatik çalışacak.',
              style: TextStyle(color: muted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _link.isLiveBlePaired
                  ? 'LilyGO eşlemesi: aktif'
                  : 'LilyGO eşlemesi: yok (uyarı yine telefonda çalışır)',
              style: TextStyle(
                color: _link.isLiveBlePaired ? AppColors.primary : muted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => VexaFinderService.simulateProximityMatch(context),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Uyarıyı dene (demo)'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Gerçek sürümde BLE yakınlık servisi bu ekranı otomatik açar.',
              style: TextStyle(fontSize: 12, color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
