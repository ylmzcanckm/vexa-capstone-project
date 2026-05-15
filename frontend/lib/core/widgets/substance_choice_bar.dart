import 'package:flutter/material.dart';
import 'package:vexa/core/constants/substance_use_options.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';

/// Sigara / alkol için tek seçimli üç seçenek.
class SubstanceChoiceBar extends StatelessWidget {
  const SubstanceChoiceBar({
    super.key,
    required this.title,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: vexa.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SubstanceUseOptions.labels.map((label) {
            final isOn = selected == label;
            return ChoiceChip(
              label: Text(label),
              selected: isOn,
              onSelected: (_) => onChanged(label),
              selectedColor: AppColors.accent.withValues(alpha: 0.22),
              labelStyle: TextStyle(
                color: isOn ? AppColors.primary : vexa.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isOn ? AppColors.accent : vexa.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
