import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/storage/bound_lilygo_store.dart';
import 'package:vexa/features/device/data/device_link_state.dart';
import 'package:vexa/features/device/data/device_repository.dart';
import 'package:vexa/features/finder/data/vexa_finder_service.dart';
import 'package:vexa/features/matching/data/match_cooldown_store.dart';
import 'package:vexa/features/matching/data/proximity_scanner.dart';

/// VEXA Finder — yakınlık eşleşme uyarısı (mavi-mor tam ekran + titreşim).
class DeviceFinderScreen extends StatefulWidget {
  const DeviceFinderScreen({super.key});

  @override
  State<DeviceFinderScreen> createState() => _DeviceFinderScreenState();
}

class _DeviceFinderScreenState extends State<DeviceFinderScreen> {
  DeviceLinkState _link = const DeviceLinkState(hasServerPair: false);
  bool _scanEnabled = false;
  Duration? _cooldownLeft;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scanEnabled = await ProximityScanner.isEnabled();
    final cooldown = await MatchCooldownStore.remaining();
    if (mounted) {
      setState(() {
        _scanEnabled = scanEnabled;
        _cooldownLeft = cooldown;
      });
    }
    try {
      final remote = await DeviceRepository.fetchMyDevice();
      if (mounted) {
        setState(() => _link = DeviceLinkState.fromServer(remote));
      }
    } catch (_) {}
  }

  Future<void> _toggleScan(bool value) async {
    if (value) {
      if (!await BoundLilyGoStore.hasBinding()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Yakınlık taraması için önce LilyGO cihazını eşle.',
            ),
          ),
        );
        return;
      }
    }
    await ProximityScanner.setEnabled(value);
    if (mounted) setState(() => _scanEnabled = value);
  }

  Future<void> _resetCooldown() async {
    await MatchCooldownStore.clear();
    if (!mounted) return;
    setState(() => _cooldownLeft = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eşleşme molası sıfırlandı (test).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('VEXA Finder')),
      body: ListView(
        padding: const EdgeInsets.all(24),
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
            'Yakınlık taraması açıkken telefon 20 sn\'de bir VEXA cihazlarını '
            'arar. Kendi LilyGO\'n bağlı olmalı; yakında uyumlu biri bulunursa '
            'LilyGO titrer, ekranında QUIZ TIME yazar ve telefonda quiz daveti açılır.',
            style: TextStyle(color: muted, height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _link.isLiveBlePaired
                ? 'LilyGO eşlemesi: aktif'
                : 'LilyGO eşlemesi: yok — otomatik eşleşme daveti çıkmaz',
            style: TextStyle(
              color: _link.isLiveBlePaired ? AppColors.primary : muted,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            value: _scanEnabled,
            onChanged: _link.isLiveBlePaired || _scanEnabled
                ? _toggleScan
                : null,
            title: const Text(
              'Yakınlık taraması',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              '20 sn\'de bir BLE taraması — LilyGO bağlıyken yakında VEXA '
              'görülürse eşleşme kontrolü yapılır.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          if (_cooldownLeft != null) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Eşleşme molası aktif'),
                subtitle: Text(
                  'Kalan: ${MatchCooldownStore.formatRemaining(_cooldownLeft!)} '
                  '— quiz bitince 2 saat yeni eşleşme olmaz.',
                ),
                trailing: TextButton(
                  onPressed: _resetCooldown,
                  child: const Text('Sıfırla'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
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
            'Firmware tarafı hazır olunca LilyGO yayını kullanıcı kimliği '
            'taşıyacak ve bu akış tamamen otomatik olacak.',
            style: TextStyle(fontSize: 12, color: muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
