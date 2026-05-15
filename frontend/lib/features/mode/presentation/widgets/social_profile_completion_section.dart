import 'package:flutter/material.dart';
import 'package:vexa/core/constants/gender_options.dart';
import 'package:vexa/core/constants/education_options.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/core/widgets/education_tab_bar.dart';
import 'package:vexa/core/widgets/substance_choice_bar.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';

/// Sosyal profil alanları; mod ekranında [showInlineSave] ile kayıt butonu gösterilir,
/// profil düzenlemede AppBar kaydı için [persist] çağrılır.
class SocialProfileEditor extends StatefulWidget {
  const SocialProfileEditor({
    super.key,
    this.showInlineSave = false,
  });

  /// true: altta "Sosyal profili kaydet" butonu.
  final bool showInlineSave;

  @override
  SocialProfileEditorState createState() => SocialProfileEditorState();
}

class SocialProfileEditorState extends State<SocialProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _about;
  late final TextEditingController _randomSkill;

  String? _gender;
  String? _education;
  String? _tobacco;
  String? _alcohol;
  final Set<String> _interests = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _height = TextEditingController();
    _weight = TextEditingController();
    _about = TextEditingController();
    _randomSkill = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final p = await UserProfileStore.load();
    final s = p?.social;
    if (!mounted) return;
    if (s != null) {
      _height.text = s.heightCm;
      _weight.text = s.weightKg;
      _about.text = s.aboutMe ?? '';
      _randomSkill.text = s.randomSkill ?? '';
      _gender = s.gender.isEmpty ? null : s.gender;
      _education = s.education.isEmpty
          ? EducationOptions.profileDefaultSelection
          : s.education;
      _tobacco = s.tobacco;
      _alcohol = s.alcohol;
      _interests
        ..clear()
        ..addAll(s.interestIds);
    } else {
      _education = EducationOptions.profileDefaultSelection;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _about.dispose();
    _randomSkill.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu' : null;

  /// AppBar "Kaydet" için. Başarıda true.
  Future<bool> persist(BuildContext context) async {
    if (_tobacco == null || _alcohol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sigara ve alkol için birer seçenek seç.')),
      );
      return false;
    }
    if (!_formKey.currentState!.validate()) return false;
    if (_interests.length < MatchInterest.minSelection ||
        _interests.length > MatchInterest.maxSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'İlgi alanı ${MatchInterest.minSelection}–${MatchInterest.maxSelection} arası olmalı.',
          ),
        ),
      );
      return false;
    }
    setState(() => _saving = true);
    final existing = await UserProfileStore.load();
    if (!mounted) return false;
    final core = existing ??
        const StoredUserProfile(name: '', surname: '', birthDateIso: '');
    final social = SocialProfileData(
      heightCm: _height.text.trim(),
      weightKg: _weight.text.trim(),
      gender: _gender ?? '',
      education: _education ?? '',
      interestIds: _interests.toList()..sort(),
      tobacco: _tobacco,
      alcohol: _alcohol,
      aboutMe: _about.text.trim().isEmpty ? null : _about.text.trim(),
      randomSkill:
          _randomSkill.text.trim().isEmpty ? null : _randomSkill.text.trim(),
    );
    await UserProfileStore.save(core.copyWith(social: social));
    try {
      await UserRepository.syncLocalProfileToServer();
    } catch (_) {
      if (!mounted) return false;
      setState(() => _saving = false);
      return false;
    }
    if (!mounted) return false;
    setState(() => _saving = false);
    return true;
  }

  Future<void> _saveInline() async {
    final ok = await persist(context);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sosyal profil kaydedildi.')),
      );
    }
  }

  InputDecoration _dec(String? label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showInlineSave) ...[
            Text(
              'Sosyal profil',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.vexa.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tanışma ve eşleşme için bu bilgileri doldur. Aşağıda keşif filtreleri ayrı tutulur.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _height,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Boy (cm)'),
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _weight,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Kilo (kg)'),
                  validator: _required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cinsiyet',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _gender,
            hint: const Text('Seç'),
            items: GenderOptions.labels
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _gender = v),
            validator: (v) => v == null ? 'Seç' : null,
            decoration: _dec(null),
          ),
          const SizedBox(height: 16),
          const Text(
            'Eğitim',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          EducationTabBar(
            selectedLabel: _education,
            allowNone: false,
            onChanged: (v) => setState(() => _education = v),
          ),
          const SizedBox(height: 16),
          SubstanceChoiceBar(
            title: 'Sigara',
            selected: _tobacco,
            onChanged: (v) => setState(() => _tobacco = v),
          ),
          const SizedBox(height: 14),
          SubstanceChoiceBar(
            title: 'Alkol',
            selected: _alcohol,
            onChanged: (v) => setState(() => _alcohol = v),
          ),
          const SizedBox(height: 16),
          Text('İlgi alanları', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MatchInterest.catalog.map((i) {
              final on = _interests.contains(i.id);
              return FilterChip(
                label: Text(i.displayLabel),
                selected: on,
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      if (_interests.length < MatchInterest.maxSelection) {
                        _interests.add(i.id);
                      }
                    } else {
                      _interests.remove(i.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _about,
            maxLines: 5,
            minLines: 2,
            decoration: _dec('Hakkımda'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _randomSkill,
            maxLines: 2,
            decoration: _dec('En rastgele yeteneğin nedir?'),
          ),
          if (widget.showInlineSave) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _saveInline,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sosyal profili kaydet'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sosyal mod gövdesinde: tamamlama formu (iç kayıt butonlu).
class SocialProfileCompletionSection extends StatelessWidget {
  const SocialProfileCompletionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SocialProfileEditor(showInlineSave: true);
  }
}
