import 'package:flutter/material.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/api/models/match_models.dart';
import 'package:vexa/core/theme/vexa_palette.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/matching/data/match_repository.dart';

/// Eşleşme geçmişi — `GET /matches/history`.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RemoteMatchHistoryItem>? _items;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await MatchRepository.fetchHistory();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Geçmiş yüklenemedi. Bağlantını kontrol et.';
        _loading = false;
      });
    }
  }

  String _modeLabel(String mode) => switch (mode) {
        'social' => 'Sosyal',
        'networking' => 'Network',
        _ => mode,
      };

  String _statusLabel(String status) => switch (status) {
        'detected' => 'Tespit edildi',
        'pending' => 'Beklemede',
        'completed' => 'Tamamlandı',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _buildBody(vexa),
    );
  }

  Widget _buildBody(VexaPalette vexa) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _load,
                child: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      );
    }

    final items = _items ?? const <RemoteMatchHistoryItem>[];
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Henüz eşleşme geçmişin yok.',
            textAlign: TextAlign.center,
            style: TextStyle(color: vexa.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final interests = item.commonInterests.take(3).join(', ');
          return Card(
            elevation: 0,
            color: vexa.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: vexa.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              title: Text(
                item.otherUser.displayName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_modeLabel(item.mode)} · ${_statusLabel(item.status)}',
                    ),
                    if (interests.isNotEmpty)
                      Text(
                        'Ortak: $interests',
                        style: TextStyle(
                          fontSize: 12,
                          color: vexa.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.matchScore}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'skor',
                    style: TextStyle(
                      fontSize: 11,
                      color: vexa.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
