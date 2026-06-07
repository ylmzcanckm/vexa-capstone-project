import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vexa/core/avatar/dicebear_dylan_avatar.dart';
import 'package:vexa/core/avatar/dylan_manual_avatar_config.dart';
import 'package:vexa/core/avatar/dylan_params_generator.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/device/data/device_avatar_auto_sync.dart';
import 'package:vexa/features/mode/presentation/screens/mode_selection_screen.dart';

/// [DiceBear Dylan](https://www.dicebear.com/styles/dylan/) — HTTP API, tasarım CC BY 4.0 (atıf).
class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({
    super.key,
    this.standaloneEdit = false,
  });

  /// true: yalnızca avatar kaydı, geri dönülür (onboarding akışı yok).
  final bool standaloneEdit;

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  late DylanManualConfig _config;
  String? _legacySeed;
  /// vxg1 diskten yüklendiyse, düzenleme yokken aynı satırı saklamak için.
  String? _persistExactVxg1;
  bool _loading = true;

  static const _moodLabels = <String, String>{
    'neutral': 'Nötr',
    'happy': 'Mutlu',
    'hopeful': 'Umutlu',
    'superHappy': 'Çok mutlu',
    'confused': 'Şaşkın',
    'sad': 'Üzgün',
    'angry': 'Somurtkan',
  };

  static const _hairLabels = <String, String>{
    'plain': 'Düz',
    'wavy': 'Dalgalı',
    'bangs': 'Kaküllü',
    'parting': 'Ortadan ayrık',
    'fluffy': 'Kabarık',
    'shaggy': 'Dağınık',
    'shortCurls': 'Kısa kıvırcık',
    'longCurls': 'Uzun kıvırcık',
    'roundBob': 'Bob',
    'buns': 'Topuz',
    'spiky': 'Dikenli',
    'flatTop': 'Düz üst',
  };

  String get _previewKey {
    if (_legacySeed != null) return _legacySeed!;
    if (_persistExactVxg1 != null) return _persistExactVxg1!;
    return _config.serialize();
  }

  void _onManualChange() {
    _persistExactVxg1 = null;
    if (_legacySeed != null) {
      _legacySeed = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final p = await UserProfileStore.load();
    if (!mounted) return;

    final stored = p?.avatarSeed ?? '';
    DylanManualConfig config;
    String? legacy;
    String? persistExactVxg1;

    final manual = DylanManualConfig.tryDeserialize(stored);
    if (manual != null) {
      config = manual;
    } else if (stored.startsWith(DicebearDylanUri.storedKeyPrefix)) {
      final parts = stored.split('|');
      if (parts.length == 3) {
        final basis = parts[1].trim();
        final v = int.tryParse(parts[2].trim()) ?? 0;
        config = basis.isNotEmpty
            ? DylanManualConfig.fromVxg1Row(basis, v)
            : DylanManualConfig.defaults();
        persistExactVxg1 = stored;
      } else {
        config = DylanManualConfig.defaults();
      }
    } else if (stored.isEmpty) {
      final b = DylanParamsGenerator.basisHexFromProfile(p);
      config = DylanManualConfig.fromVxg1Row(b, 0);
    } else {
      config = DylanManualConfig.defaults();
      legacy = stored;
    }

    setState(() {
      _config = config;
      _legacySeed = legacy;
      _persistExactVxg1 = persistExactVxg1;
      _loading = false;
    });
  }

  Future<void> _saveAndContinue() async {
    final p = await UserProfileStore.load();
    if (!mounted) return;
    final core = p ??
        const StoredUserProfile(name: '', surname: '', birthDateIso: '');
    final seed = _persistExactVxg1 ?? _legacySeed ?? _config.serialize();
    final updated = core.copyWith(avatarSeed: seed);
    await UserProfileStore.save(updated);
    try {
      await UserRepository.pushProfile(updated);
      await UserRepository.syncDefaultAvatarIfNeeded();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avatar sunucuya kaydedilemedi: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sunucu bağlantısı yok; avatar yerelde kaydedildi.')),
      );
    }
    if (!mounted) return;
    if (widget.standaloneEdit) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Avatar kaydedildi. Cihaza gönderiliyor…')),
      );
      final deviceName = await DeviceAvatarAutoSync.syncIfPaired(seed);
      if (!mounted) return;
      if (deviceName != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Avatar $deviceName cihazına gönderildi.')),
        );
      }
      Navigator.of(context).pop(true);
      return;
    }
    await OnboardingPreferences.setComplete(true);
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ModeSelectionScreen(),
      ),
      (_) => false,
    );
  }

  Future<void> _openDicebear() async {
    final u = Uri.parse('https://www.dicebear.com/styles/dylan/');
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  Color _hexToColor(String hex) {
    final h = hex.trim().toLowerCase();
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vexa = context.vexa;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Avatar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          children: [
            Text(
              'Avatarın',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'İfade, saç şekli, ten ve saç rengini aşağıdan seç; önizleme gri zeminde — '
              'beyaz saç da okunur. Kaydettiğinde seçimlerin cihazda saklanır.',
              style: textTheme.bodyMedium?.copyWith(
                color: vexa.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: vexa.avatarPreviewBackdrop,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Center(
                        child: DicebearDylanAvatar(
                          seed: _previewKey,
                          size: 182,
                          contrastBackdrop: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_legacySeed != null) ...[
              const SizedBox(height: 8),
              Text(
                'Eski tek-seed avatarın korunuyor; aşağıdan bir alan değiştirirsen yeni manuel '
                'sisteme geçilir.',
                style: textTheme.bodySmall?.copyWith(
                  color: vexa.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Özelleştir',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _LabeledDropdown<String>(
              label: 'İfade',
              value: _config.mood,
              items: DylanParamsGenerator.moods,
              itemLabel: (e) => _moodLabels[e] ?? e,
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _onManualChange();
                  _config = _config.copyWith(mood: v);
                });
              },
            ),
            const SizedBox(height: 14),
            _LabeledDropdown<String>(
              label: 'Saç şekli',
              value: _config.hair,
              items: DylanParamsGenerator.hairs,
              itemLabel: (e) => _hairLabels[e] ?? e,
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _onManualChange();
                  _config = _config.copyWith(hair: v);
                });
              },
            ),
            const SizedBox(height: 14),
            _LabeledDropdown<String>(
              label: 'Ten rengi',
              value: _config.skinColor,
              items: DylanParamsGenerator.skinColors,
              itemLabel: (e) => '#$e',
              leading: (e) => _Swatch(color: _hexToColor(e)),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _onManualChange();
                  _config = _config.copyWith(skinColor: v);
                });
              },
            ),
            const SizedBox(height: 14),
            _LabeledDropdown<String>(
              label: 'Saç rengi',
              value: _config.hairColor,
              items: DylanParamsGenerator.hairColors,
              itemLabel: (e) => '#$e',
              leading: (e) => _Swatch(color: _hexToColor(e)),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _onManualChange();
                  _config = _config.copyWith(hairColor: v);
                });
              },
            ),
            Text(
              'Sakal / yüz kılı',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: vexa.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Yok')),
                ButtonSegment(value: 100, label: Text('Var')),
              ],
              selected: {_config.facialHairProbability > 0 ? 100 : 0},
              onSelectionChanged: (s) {
                final v = s.first;
                setState(() {
                  _onManualChange();
                  _config = _config.copyWith(facialHairProbability: v);
                });
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Lisans',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'DiceBear kodu MIT; Dylan görseli CC BY 4.0 — ticari kullanımda atıf ve lisans '
              'koşullarına uy. Ayrıntı için DiceBear sayfasına bak.',
              style: textTheme.bodySmall?.copyWith(
                color: vexa.textSecondary,
                height: 1.4,
              ),
            ),
            TextButton(
              onPressed: _openDicebear,
              child: const Text('DiceBear · Dylan sayfası'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveAndContinue,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                widget.standaloneEdit
                    ? 'Kaydet'
                    : 'Kaydet ve mod seçimine geç',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.vexa.border),
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.leading,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final Widget Function(T)? leading;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: vexa.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: vexa.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: vexa.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: vexa.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map(
                    (e) => DropdownMenuItem<T>(
                      value: e,
                      child: Row(
                        children: [
                          if (leading != null) ...[
                            leading!(e),
                            const SizedBox(width: 10),
                          ],
                          Expanded(child: Text(itemLabel(e))),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
