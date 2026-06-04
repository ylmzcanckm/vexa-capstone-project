import 'package:flutter/material.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/device/data/device_repository.dart';

/// BLE / cihaz ayarları — bağlantı durumu + yerel tercihler (donanım sonra).
class BleDeviceSettingsScreen extends StatefulWidget {
  const BleDeviceSettingsScreen({super.key});

  @override
  State<BleDeviceSettingsScreen> createState() => _BleDeviceSettingsScreenState();
}

class _BleDeviceSettingsScreenState extends State<BleDeviceSettingsScreen> {
  final _ble = BleAvatarTransferService();
  bool _linked = false;
  bool _sending = false;
  String? _pairedDeviceName;
  int _vibrationIndex = 1;
  double _brightness = 0.5;
  bool _autoBrightness = false;
  int _screenTimeoutIndex = 1;

  @override
  void dispose() {
    _ble.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadLinked();
  }

  Future<void> _loadLinked() async {
    final linked = await DeviceConnectionPreferences.isLinked();
    String? name;
    try {
      final remote = await DeviceRepository.fetchMyDevice();
      final device = remote?['device'] as Map<String, dynamic>?;
      name = device?['deviceName'] as String?;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _linked = linked || name != null;
        _pairedDeviceName = name;
      });
    }
  }

  Future<void> _resendAvatar() async {
    final profile = await UserProfileStore.load();
    if (profile == null || profile.avatarSeed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıtlı avatar yok.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final results = await _ble.scan(timeout: const Duration(seconds: 8));
      if (results.isEmpty) {
        throw Exception('VEXA cihazı bulunamadı.');
      }
      await _ble.connect(results.first.device);
      await _ble.transferAvatarFromSeed(profile.avatarSeed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar cihaza gönderildi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      await _ble.disconnect();
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final surface = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz ayarları'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    _linked ? Icons.link_rounded : Icons.link_off_rounded,
                    color: _linked ? AppColors.primary : muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _linked
                          ? 'Cihaz eşlemesi tamam (simülasyon). BLE canlı veri '
                              'donanım hazır olunca burada görünecek.'
                          : 'Henüz cihaz eşlenmedi. Ana akışta “Cihazı bağla” '
                              'adımını tamamla.',
                      style: textTheme.bodySmall?.copyWith(
                        color: muted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (BleAvatarTransferService.isSupported) ...[
            FilledButton.icon(
              onPressed: _sending ? null : _resendAvatar,
              icon: const Icon(Icons.send_rounded),
              label: Text(_sending ? 'Gönderiliyor…' : 'Avatarı cihaza yeniden gönder'),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 20),
          _SectionTitle(text: 'Bağlı cihaz', textTheme: textTheme),
          const SizedBox(height: 8),
          _tile('Pil seviyesi', _linked ? '— % (yakında)' : '—'),
          _tile(
            'Bağlantı durumu',
            _linked
                ? (_pairedDeviceName ?? 'Eşlendi')
                : 'Bağlı değil',
          ),
          _tile('Firmware sürümü', '—'),
          _tile('Son senkronizasyon', '—'),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Titreşim', textTheme: textTheme),
          const SizedBox(height: 4),
          Text(
            'Tercihler yerelde saklanır; cihaza yazma BLE ile gelecek.',
            style: textTheme.bodySmall?.copyWith(color: muted, height: 1.35),
          ),
          const SizedBox(height: 8),
          _ChoiceRow(
            labels: const ['Güçlü', 'Hafif', 'Kapalı'],
            selectedIndex: _vibrationIndex,
            onSelected: (i) => setState(() => _vibrationIndex = i),
            textTheme: textTheme,
            surface: surface,
            border: border,
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Parlaklık', textTheme: textTheme),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Otomatik parlaklık'),
            value: _autoBrightness,
            onChanged: (v) => setState(() => _autoBrightness = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Manuel', style: textTheme.labelMedium),
          ),
          Slider(
            value: _brightness,
            onChanged: _autoBrightness
                ? null
                : (v) => setState(() => _brightness = v),
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Ekran zaman aşımı', textTheme: textTheme),
          const SizedBox(height: 8),
          _ChoiceRow(
            labels: const ['10 sn', '30 sn', 'Always on'],
            selectedIndex: _screenTimeoutIndex,
            onSelected: (i) => setState(() => _screenTimeoutIndex = i),
            textTheme: textTheme,
            surface: surface,
            border: border,
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      dense: true,
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
  final ValueChanged<int> onSelected;
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
          onSelected: (_) => onSelected(i),
          side: BorderSide(color: border),
          backgroundColor: surface,
        );
      }),
    );
  }
}
