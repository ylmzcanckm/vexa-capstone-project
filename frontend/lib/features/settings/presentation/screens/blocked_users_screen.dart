import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/features/settings/providers/settings_providers.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  Future<void> _addBlocked(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    try {
      final added = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Engelle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'İsim veya tanımlayıcı',
              hintText: 'Örn. kullanıcı adı',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ekle'),
            ),
          ],
        ),
      );
      if (added == true) {
        await ref.read(blockedUsersProvider.notifier).add(controller.text);
      }
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedUsersProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engelle / gizle'),
        actions: [
          IconButton(
            onPressed: () => _addBlocked(context, ref),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Ekle',
          ),
        ],
      ),
      body: blocked.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Engellenen kimse yok. Eşleşmek istemediğin birini '
                  'buraya manuel ekleyebilirsin (yerel liste; sunucu senkronu yakında).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, height: 1.45),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: blocked.length,
              itemBuilder: (context, index) {
                final entry = blocked[index];
                return ListTile(
                  leading: const Icon(Icons.block_rounded),
                  title: Text(entry.displayName),
                  subtitle: entry.note.isNotEmpty ? Text(entry.note) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () =>
                        ref.read(blockedUsersProvider.notifier).remove(entry.id),
                  ),
                );
              },
            ),
    );
  }
}
