import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/core/constants/gender_options.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/core/widgets/education_tab_bar.dart';
import 'package:vexa/features/matching/domain/discovery_substance_filter.dart';
import 'package:vexa/features/matching/presentation/providers/discovery_filters_provider.dart';

/// Sosyal / tanışma tarafında kullanılacak filtreler (ileride BLE + backend ile bağlanır).
class DiscoveryFiltersSection extends ConsumerWidget {
  const DiscoveryFiltersSection({super.key});

  static const double _ageMin = 18;
  static const double _ageMax = 80;
  static const double _heightMin = 140;
  static const double _heightMax = 220;
  static const double _weightMin = 40;
  static const double _weightMax = 150;

  static String _substanceSubtitle(DiscoverySubstanceFilter f) {
    return switch (f) {
      DiscoverySubstanceFilter.any => 'Filtre yok (tümü)',
      DiscoverySubstanceFilter.onlyNonUsers => 'Yalnızca “Kullanmıyor”',
      DiscoverySubstanceFilter.onlyUsers => 'Düzenli veya sosyal içenler',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(discoveryFiltersProvider);
    final n = ref.read(discoveryFiltersProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final vexa = context.vexa;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tanışma filtreleri',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: vexa.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: n.reset,
              child: const Text('Sıfırla'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Yaş, boy, kilo ve diğer tercihlerle kiminle tanışacağını belirle. '
          'Boş bıraktığın filtreler uygulanmaz.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        _FilterCard(
          title: 'Yaş',
          subtitle:
              '${s.ageRange.start.round()} – ${s.ageRange.end.round()} yaş',
          child: RangeSlider(
            values: s.ageRange,
            min: _ageMin,
            max: _ageMax,
            divisions: (_ageMax - _ageMin).round(),
            labels: RangeLabels(
              '${s.ageRange.start.round()}',
              '${s.ageRange.end.round()}',
            ),
            activeColor: AppColors.accent,
            onChanged: n.setAgeRange,
          ),
        ),
        const SizedBox(height: 12),
        _FilterCard(
          title: 'Tanışmak istediğin cinsiyet',
          subtitle: s.selectedGenders.isEmpty
              ? 'Hepsi'
              : s.selectedGenders.join(', '),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GenderOptions.labels.map((label) {
                final selected = s.selectedGenders.contains(label);
                return FilterChip(
                  label: Text(
                    label,
                    style: const TextStyle(fontSize: 13),
                  ),
                  selected: selected,
                  onSelected: (_) => n.toggleGender(label),
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.accent,
                  side: BorderSide(
                    color: selected ? AppColors.accent : vexa.border,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FilterCard(
          title: 'Boy (cm)',
          subtitle:
              '${s.heightRange.start.round()} – ${s.heightRange.end.round()} cm',
          child: RangeSlider(
            values: s.heightRange,
            min: _heightMin,
            max: _heightMax,
            divisions: ((_heightMax - _heightMin) / 2).round(),
            labels: RangeLabels(
              '${s.heightRange.start.round()}',
              '${s.heightRange.end.round()}',
            ),
            activeColor: AppColors.accent,
            onChanged: n.setHeightRange,
          ),
        ),
        const SizedBox(height: 12),
        _FilterCard(
          title: 'Kilo (kg)',
          subtitle:
              '${s.weightRange.start.round()} – ${s.weightRange.end.round()} kg',
          child: RangeSlider(
            values: s.weightRange,
            min: _weightMin,
            max: _weightMax,
            divisions: ((_weightMax - _weightMin) / 2).round(),
            labels: RangeLabels(
              '${s.weightRange.start.round()}',
              '${s.weightRange.end.round()}',
            ),
            activeColor: AppColors.accent,
            onChanged: n.setWeightRange,
          ),
        ),
        const SizedBox(height: 12),
        _FilterCard(
          title: 'Eğitim durumu',
          subtitle: s.educationFloor == null
              ? 'Filtre yok (tümü)'
              : 'Alt sınır: ${s.educationFloor} — bu ve daha yüksek düzeyler',
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: EducationTabBar(
              selectedLabel: s.educationFloor,
              allowNone: true,
              onChanged: n.setEducationFloor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FilterCard(
          title: 'Sigara',
          subtitle: _substanceSubtitle(s.tobaccoFilter),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DiscoverySubstanceFilter.values.map((mode) {
                final selected = s.tobaccoFilter == mode;
                return ChoiceChip(
                  label: Text(
                    switch (mode) {
                      DiscoverySubstanceFilter.any => 'Farketmez',
                      DiscoverySubstanceFilter.onlyNonUsers => 'Kullanmayanlar',
                      DiscoverySubstanceFilter.onlyUsers => 'Kullananlar',
                    },
                    style: const TextStyle(fontSize: 13),
                  ),
                  selected: selected,
                  onSelected: (_) => n.setTobaccoFilter(mode),
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : vexa.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.accent : vexa.border,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FilterCard(
          title: 'Alkol',
          subtitle: _substanceSubtitle(s.alcoholFilter),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DiscoverySubstanceFilter.values.map((mode) {
                final selected = s.alcoholFilter == mode;
                return ChoiceChip(
                  label: Text(
                    switch (mode) {
                      DiscoverySubstanceFilter.any => 'Farketmez',
                      DiscoverySubstanceFilter.onlyNonUsers => 'Kullanmayanlar',
                      DiscoverySubstanceFilter.onlyUsers => 'Kullananlar',
                    },
                    style: const TextStyle(fontSize: 13),
                  ),
                  selected: selected,
                  onSelected: (_) => n.setAlcoholFilter(mode),
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : vexa.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.accent : vexa.border,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return Material(
      color: vexa.cardFill,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: vexa.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            child,
          ],
        ),
      ),
    );
  }
}
