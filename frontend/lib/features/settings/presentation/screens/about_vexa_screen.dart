import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hakkında — sürüm (pubspec ile uyumlu).
class AboutVexaScreen extends StatelessWidget {
  const AboutVexaScreen({super.key});

  static const version = '1.0.0+1';
  static final _repoUri = Uri.parse('https://github.com/ylmzcanckm/vexa-project');

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('VEXA hakkında')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'VEXA',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Sürüm $version', style: textTheme.titleMedium),
          const SizedBox(height: 20),
          Text(
            'Giyilebilir sosyal ve network deneyimi. Mod seçimi, profil ve '
            'eşleşme geçmişi tek uygulamada.',
            style: textTheme.bodyMedium?.copyWith(
              color: muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.code_rounded),
            title: const Text('Kaynak kodu'),
            subtitle: const Text('vexa-project (GitHub)'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _open(_repoUri),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Kullanım koşulları'),
            subtitle: Text('Yakında', style: TextStyle(color: muted)),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
