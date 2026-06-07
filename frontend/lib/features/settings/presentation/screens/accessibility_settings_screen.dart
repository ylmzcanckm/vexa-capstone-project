import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/features/settings/providers/settings_providers.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  static const _scaleOptions = <({double value, String label})>[
    (value: 0.9, label: 'Küçük'),
    (value: 1.0, label: 'Normal'),
    (value: 1.15, label: 'Büyük'),
    (value: 1.3, label: 'Çok büyük'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.read(accessibilitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Erişilebilirlik')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(
            'Metin boyutu',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<double>(
            segments: _scaleOptions
                .map(
                  (e) => ButtonSegment<double>(
                    value: e.value,
                    label: Text(e.label),
                  ),
                )
                .toList(),
            selected: {settings.textScale},
            onSelectionChanged: (s) => notifier.setTextScale(s.first),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            secondary: const Icon(Icons.format_bold_rounded),
            title: const Text('Kalın metin'),
            value: settings.boldText,
            onChanged: notifier.setBoldText,
          ),
        ],
      ),
    );
  }
}
