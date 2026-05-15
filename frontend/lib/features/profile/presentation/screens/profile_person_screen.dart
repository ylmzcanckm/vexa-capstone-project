import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vexa/core/avatar/dicebear_dylan_avatar.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/utils/user_age.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';
import 'package:vexa/features/onboarding/presentation/screens/avatar_selection_screen.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';
import 'package:vexa/features/profile/presentation/screens/profile_edit_screen.dart';

/// Mod sekmesine göre ilgili profil alanlarını gösterir; düzenle aynı kapsamı açar.
class ProfilePersonScreen extends StatefulWidget {
  const ProfilePersonScreen({super.key, required this.profileContext});

  final VexaMode profileContext;

  @override
  State<ProfilePersonScreen> createState() => _ProfilePersonScreenState();
}

class _ProfilePersonScreenState extends State<ProfilePersonScreen> {
  StoredUserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final p = await UserProfileStore.load();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  Future<void> _openEdit() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ProfileEditScreen(editScope: widget.profileContext),
      ),
    );
    if (ok == true && mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final vexa = context.vexa;

    return Scaffold(
      backgroundColor: vexa.scaffold,
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: _loading ? null : _openEdit,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Henüz kayıtlı profil yok. Onboarding ile profil oluştur.',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Material(
                    color: vexa.surface,
                    elevation: 2,
                    shadowColor: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () async {
                                  final ok = await Navigator.of(context)
                                      .push<bool>(
                                    MaterialPageRoute<bool>(
                                      builder: (_) =>
                                          const AvatarSelectionScreen(
                                        standaloneEdit: true,
                                      ),
                                    ),
                                  );
                                  if (ok == true && mounted) await _reload();
                                },
                                child: Tooltip(
                                  message: 'Avatarı düzenle',
                                  child: _AvatarCircle(
                                    letter: _profile!.name.isNotEmpty
                                        ? _profile!.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : 'V',
                                    avatarSeed: _profile!.avatarSeed,
                                    textTheme: textTheme,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _ProfileRow(
                            label: 'İsim',
                            value: _profile!.name.isEmpty ? '—' : _profile!.name,
                            textTheme: textTheme,
                          ),
                          const Divider(height: 28),
                          _ProfileRow(
                            label: 'Soyisim',
                            value: _profile!.surname.isEmpty
                                ? '—'
                                : _profile!.surname,
                            textTheme: textTheme,
                          ),
                          const Divider(height: 28),
                          _ProfileRow(
                            label: 'Yaş',
                            value: UserAge.displayAgeAndBirth(
                              _profile!.birthDateIso,
                            ),
                            textTheme: textTheme,
                          ),
                          if (widget.profileContext == VexaMode.social) ...[
                            ..._socialSection(_profile!, textTheme),
                          ] else if (widget.profileContext ==
                              VexaMode.business) ...[
                            ..._businessSection(_profile!, textTheme),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  List<Widget> _socialSection(StoredUserProfile p, TextTheme textTheme) {
    final s = p.social;
    if (s == null) {
      return [
        const Divider(height: 28),
        Text(
          'Sosyal profil henüz tamamlanmadı. Sosyal mod ekranından doldurabilirsin.',
          style: textTheme.bodyMedium?.copyWith(
            color: context.vexa.textSecondary,
            height: 1.45,
          ),
        ),
      ];
    }
    return [
      const Divider(height: 28),
      _ProfileRow(
        label: 'Boy / kilo',
        value: '${s.heightCm} cm / ${s.weightKg} kg',
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Cinsiyet',
        value: s.gender.isEmpty ? '—' : s.gender,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Eğitim',
        value: s.education.isEmpty ? '—' : s.education,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Sigara',
        value: s.tobacco ?? '—',
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Alkol',
        value: s.alcohol ?? '—',
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      Text(
        'Hobiler',
        style: textTheme.labelLarge?.copyWith(
          color: context.vexa.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        _hobbiesText(s.interestIds),
        style: textTheme.bodyMedium?.copyWith(
          color: context.vexa.textPrimary,
          height: 1.45,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Profil bilgileri',
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.vexa.textPrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Hakkımda',
        style: textTheme.labelMedium?.copyWith(
          color: context.vexa.textSecondary,
        ),
      ),
      const SizedBox(height: 12),
      _InfoBox(
        text: s.aboutMe ??
            'Henüz yazılmadı. Sosyal mod veya düzenle ile ekleyebilirsin.',
        textTheme: textTheme,
      ),
      const SizedBox(height: 20),
      Text(
        'En rastgele yeteneğin nedir?',
        style: textTheme.labelMedium?.copyWith(
          color: context.vexa.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      _InfoBox(
        text: s.randomSkill ??
            'Henüz yazılmadı. Sosyal mod veya düzenle ile ekleyebilirsin.',
        textTheme: textTheme,
      ),
    ];
  }

  List<Widget> _businessSection(StoredUserProfile p, TextTheme textTheme) {
    final b = p.business;
    if (b == null) {
      return [
        const Divider(height: 28),
        Text(
          'Network profili henüz tamamlanmadı. Business mod ekranından doldurabilirsin.',
          style: textTheme.bodyMedium?.copyWith(
            color: context.vexa.textSecondary,
            height: 1.45,
          ),
        ),
      ];
    }
    return [
      const Divider(height: 28),
      if (b.networkPhotoPath != null &&
          File(b.networkPhotoPath!).existsSync()) ...[
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(b.networkPhotoPath!),
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      _ProfileRow(
        label: 'Ünvan',
        value: b.jobTitle.isEmpty ? '—' : b.jobTitle,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Şirket / Üniversite',
        value: b.companyOrUniversity.isEmpty ? '—' : b.companyOrUniversity,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Bölüm / alan',
        value: b.departmentOrField.isEmpty ? '—' : b.departmentOrField,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Şehir / ülke',
        value: b.cityCountry.isEmpty ? '—' : b.cityCountry,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _ProfileRow(
        label: 'Çalışma durumu',
        value: b.workStatus ?? '—',
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      Text(
        'Professional tags',
        style: textTheme.labelLarge?.copyWith(
          color: context.vexa.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      _TagWrap(labels: b.professionalTags, textTheme: textTheme),
      const Divider(height: 28),
      Text(
        'Currently looking for',
        style: textTheme.labelLarge?.copyWith(
          color: context.vexa.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      _TagWrap(labels: b.lookingFor, textTheme: textTheme),
      const Divider(height: 28),
      Text(
        'Bio / elevator pitch',
        style: textTheme.labelLarge?.copyWith(
          color: context.vexa.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      _InfoBox(
        text: b.elevatorPitch.isEmpty ? '—' : b.elevatorPitch,
        textTheme: textTheme,
      ),
      if (b.linkedinUrl != null && b.linkedinUrl!.isNotEmpty) ...[
        const Divider(height: 28),
        _ProfileRow(
          label: 'LinkedIn',
          value: b.linkedinUrl!,
          textTheme: textTheme,
        ),
      ],
      if (b.workEmail != null && b.workEmail!.isNotEmpty) ...[
        const Divider(height: 28),
        _ProfileRow(
          label: 'İş e-postası',
          value: b.workEmail!,
          textTheme: textTheme,
        ),
      ],
    ];
  }

  static String _hobbiesText(List<String> interestIds) {
    if (interestIds.isEmpty) return '—';
    return interestIds
        .map((id) => MatchInterest.byId(id)?.displayLabel ?? id)
        .join(' · ');
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({
    required this.labels,
    required this.textTheme,
  });

  final List<String> labels;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return Text('—', style: textTheme.bodyMedium);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((t) {
        final vexa = context.vexa;
        return Chip(
          label: Text(t),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: vexa.border),
          backgroundColor: vexa.surfaceElevated,
        );
      }).toList(),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.letter,
    required this.avatarSeed,
    required this.textTheme,
  });

  final String letter;
  final String avatarSeed;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final useDicebear = avatarSeed.trim().isNotEmpty;
    final vexa = context.vexa;

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: useDicebear ? vexa.avatarPreviewBackdrop : vexa.surface,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: useDicebear
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: DicebearDylanAvatar(
                    seed: avatarSeed,
                    size: 88,
                    contrastBackdrop: false,
                  ),
                )
              : Center(
                  child: Text(
                    letter,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: context.vexa.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: context.vexa.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.text,
    required this.textTheme,
  });

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: vexa.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: vexa.border),
      ),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: context.vexa.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
