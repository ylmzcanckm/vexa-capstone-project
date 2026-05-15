import 'package:flutter/material.dart';
import 'package:vexa/core/constants/education_options.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';

/// Tek seçimli, yatay kaydırmalı eğitim sekmeleri.
class EducationTabBar extends StatefulWidget {
  const EducationTabBar({
    super.key,
    required this.selectedLabel,
    required this.onChanged,
    this.allowNone = false,
    this.noneLabel = 'Tümü',
  });

  /// [allowNone] true iken `null` = filtre yok.
  final String? selectedLabel;
  final ValueChanged<String?> onChanged;
  final bool allowNone;
  final String noneLabel;

  @override
  State<EducationTabBar> createState() => _EducationTabBarState();
}

class _EducationTabBarState extends State<EducationTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  late List<String> _tabLabels;

  int _indexForSelection(String? sel) {
    if (widget.allowNone && sel == null) return 0;
    if (sel == null) return 0;
    final j = EducationOptions.labels.indexOf(sel);
    if (j < 0) return widget.allowNone ? 0 : 0;
    return widget.allowNone ? j + 1 : j;
  }

  @override
  void initState() {
    super.initState();
    _tabLabels = widget.allowNone
        ? [widget.noneLabel, ...EducationOptions.labels]
        : [...EducationOptions.labels];
    _controller = TabController(
      length: _tabLabels.length,
      vsync: this,
      initialIndex: _indexForSelection(widget.selectedLabel),
    );
  }

  @override
  void didUpdateWidget(EducationTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allowNone != widget.allowNone ||
        oldWidget.noneLabel != widget.noneLabel) {
      _controller.dispose();
      _tabLabels = widget.allowNone
          ? [widget.noneLabel, ...EducationOptions.labels]
          : [...EducationOptions.labels];
      _controller = TabController(
        length: _tabLabels.length,
        vsync: this,
        initialIndex: _indexForSelection(widget.selectedLabel),
      );
    } else if (oldWidget.selectedLabel != widget.selectedLabel) {
      final next = _indexForSelection(widget.selectedLabel);
      if (_controller.index != next && next < _controller.length) {
        _controller.index = next;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int i) {
    if (_controller.index != i) {
      _controller.animateTo(i);
    }
    if (widget.allowNone && i == 0) {
      widget.onChanged(null);
    } else {
      final j = widget.allowNone ? i - 1 : i;
      widget.onChanged(EducationOptions.labels[j]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return TabBar(
      controller: _controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.primary,
      unselectedLabelColor: vexa.textSecondary,
      indicatorColor: AppColors.accent,
      indicatorWeight: 3,
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      onTap: _handleTap,
      tabs: _tabLabels.map((t) {
        return Tab(
          height: 48,
          child: Text(
            t,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
    );
  }
}
