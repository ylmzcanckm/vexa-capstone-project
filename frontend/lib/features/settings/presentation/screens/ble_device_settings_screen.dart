import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';

/// BLE / cihaz ayarları (ses çipi yok — yalnızca titreşim, parlaklık, ekran).
class BleDeviceSettingsScreen extends StatelessWidget {
  const BleDeviceSettingsScreen({super.key});

  static const _soon =
      'Donanım ve BLE hazır olduğunda burası canlı veriyle dolar.';

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
                  Icon(Icons.info_outline_rounded, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _soon,
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
          const SizedBox(height: 20),
          _SectionTitle(text: 'Bağlı cihaz', textTheme: textTheme),
          const SizedBox(height: 8),
          _tile(context, 'Pil seviyesi', '— %'),
          _tile(context, 'Bağlantı durumu', 'Bağlı değil (yer tutucu)'),
          _tile(context, 'Firmware sürümü', '—'),
          _tile(context, 'Son senkronizasyon', '—'),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Titreşim', textTheme: textTheme),
          const SizedBox(height: 4),
          Text(
            'Cihazda ses çipi yok; bildirimler yalnızca titreşim ile verilir.',
            style: textTheme.bodySmall?.copyWith(color: muted, height: 1.35),
          ),
          const SizedBox(height: 8),
          _ChoiceRow(
            labels: const ['Güçlü', 'Hafif', 'Kapalı'],
            textTheme: textTheme,
            surface: surface,
            border: border,
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Parlaklık', textTheme: textTheme),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Otomatik parlaklık'),
            value: false,
            onChanged: null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Manuel slider', style: textTheme.labelMedium),
          ),
          Slider(value: 0.5, onChanged: null),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Ekran zaman aşımı', textTheme: textTheme),
          const SizedBox(height: 8),
          _ChoiceRow(
            labels: const ['10 sn', '30 sn', 'Always on'],
            textTheme: textTheme,
            surface: surface,
            border: border,
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      dense: true,
      enabled: false,
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
    required this.textTheme,
    required this.surface,
    required this.border,
  });

  final List<String> labels;
  final TextTheme textTheme;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((l) {
        return Chip(
          label: Text(l, style: textTheme.labelLarge),
          side: BorderSide(color: border),
          backgroundColor: surface,
        );
      }).toList(),
    );
  }
}
