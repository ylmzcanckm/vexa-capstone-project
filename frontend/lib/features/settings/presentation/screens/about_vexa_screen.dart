import 'package:flutter/material.dart';

/// Hakkında — sürüm wireframe’deki gibi sabit (pubspec ile uyumlu).
class AboutVexaScreen extends StatelessWidget {
  const AboutVexaScreen({super.key});

  static const version = '1.0.0+1';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('VEXA hakkında')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VEXA',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text('Sürüm $version', style: textTheme.titleMedium),
            const SizedBox(height: 20),
            Text(
              'Giyilebilir sosyal ve network deneyimi. Ayrıntılı hakkında metni ve '
              'yasal bağlantılar sonraki iterasyonlarda burada olacak.',
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
