import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/features/settings/providers/settings_providers.dart';

class KvkkConsentScreen extends ConsumerWidget {
  const KvkkConsentScreen({super.key});

  static const _body =
      'VEXA; hesap oluşturma, profil, eşleşme ve cihaz eşlemesi için '
      'kimlik ve profil verilerini işler. Veriler güvenli sunucularda saklanır.\n\n'
      '• İşleme amacı: hizmet sunumu, eşleşme, güvenlik\n'
      '• Saklama: hesabın aktif olduğu süre\n'
      '• Hakların: erişim, düzeltme, silme talebi\n\n'
      'Tam metin ve veri sorumlusu bilgileri resmi sürümde güncellenecektir. '
      'Devam ederek bu özet metni okuduğunu onaylarsın.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accepted = ref.watch(privacySettingsProvider).kvkkAcceptedAtIso;

    return Scaffold(
      appBar: AppBar(title: const Text('KVKK')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ),
            if (accepted != null) ...[
              const SizedBox(height: 12),
              Text(
                'Onay tarihi: $accepted',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await ref.read(privacySettingsProvider.notifier).acceptKvkk();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('KVKK onayı kaydedildi.')),
                );
                Navigator.of(context).pop();
              },
              child: Text(accepted == null ? 'Okudum, onaylıyorum' : 'Onayı yenile'),
            ),
          ],
        ),
      ),
    );
  }
}
