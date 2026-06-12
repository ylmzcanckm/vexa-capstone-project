import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/core/utils/user_age.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';
import 'package:vexa/features/mode/presentation/vexa_mode_style.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';

/// Eşleşilen kişinin sosyal veya network kartı (salt okunur).
class MatchedPersonCardScreen extends StatelessWidget {
  const MatchedPersonCardScreen({
    super.key,
    required this.profileContext,
    required this.displayName,
    this.profileBio,
    this.matchScore,
    this.quizPercent,
  });

  final VexaMode profileContext;
  final String displayName;
  final String? profileBio;
  final int? matchScore;
  final int? quizPercent;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    final textTheme = Theme.of(context).textTheme;
    final profile = ProfileBioCodec.tryDecodeProfileOnly(profileBio);
    final name = profile?.name.isNotEmpty == true
        ? '${profile!.name} ${profile.surname}'.trim()
        : displayName;

    return Scaffold(
      backgroundColor: vexa.scaffold,
      appBar: AppBar(
        title: Text(
          profileContext == VexaMode.business
              ? 'Network kartı'
              : 'Kişi kartı',
        ),
      ),
      body: SingleChildScrollView(
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
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: profileContext.accentColor
                        .withValues(alpha: 0.15),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: profileContext.accentColor,
                      ),
                    ),
                  ),
                ),
                if (matchScore != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Chip(
                      label: Text(
                        quizPercent != null
                            ? 'Uyum %$matchScore · Quiz %$quizPercent'
                            : 'Uyum %$matchScore',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (profile == null) ...[
                  Text(
                    name,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Profil detayları henüz paylaşılmamış.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: vexa.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ] else ...[
                  _CardRow(
                    label: 'İsim',
                    value: name.isEmpty ? '—' : name,
                    textTheme: textTheme,
                  ),
                  const Divider(height: 28),
                  _CardRow(
                    label: 'Yaş',
                    value: UserAge.displayAgeAndBirth(profile.birthDateIso),
                    textTheme: textTheme,
                  ),
                  if (profileContext == VexaMode.social) ...[
                    ..._socialFields(profile, textTheme, vexa.textSecondary),
                  ] else if (profileContext == VexaMode.business) ...[
                    ..._networkFields(profile, textTheme, vexa.textSecondary),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _socialFields(
    StoredUserProfile p,
    TextTheme textTheme,
    Color muted,
  ) {
    final s = p.social;
    if (s == null) {
      return [
        const Divider(height: 28),
        Text(
          'Sosyal profil henüz tamamlanmamış.',
          style: textTheme.bodyMedium?.copyWith(color: muted, height: 1.45),
        ),
      ];
    }
    return [
      const Divider(height: 28),
      _CardRow(
        label: 'Boy / kilo',
        value: '${s.heightCm} cm / ${s.weightKg} kg',
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _CardRow(
        label: 'Cinsiyet',
        value: s.gender.isEmpty ? '—' : s.gender,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      Text(
        'Hobiler',
        style: textTheme.labelLarge?.copyWith(
          color: muted,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        s.interestIds.isEmpty
            ? '—'
            : s.interestIds
                .map((id) => MatchInterest.byId(id)?.label ?? id)
                .join(', '),
        style: textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      const SizedBox(height: 20),
      Text(
        'Hakkımda',
        style: textTheme.labelMedium?.copyWith(color: muted),
      ),
      const SizedBox(height: 8),
      _InfoBox(text: s.aboutMe ?? '—', textTheme: textTheme),
    ];
  }

  List<Widget> _networkFields(
    StoredUserProfile p,
    TextTheme textTheme,
    Color muted,
  ) {
    final b = p.business;
    if (b == null) {
      return [
        const Divider(height: 28),
        Text(
          'Network profili henüz tamamlanmamış.',
          style: textTheme.bodyMedium?.copyWith(color: muted, height: 1.45),
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
      _CardRow(
        label: 'Ünvan',
        value: b.jobTitle.isEmpty ? '—' : b.jobTitle,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _CardRow(
        label: 'Şirket / Üniversite',
        value: b.companyOrUniversity.isEmpty ? '—' : b.companyOrUniversity,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _CardRow(
        label: 'Bölüm / alan',
        value: b.departmentOrField.isEmpty ? '—' : b.departmentOrField,
        textTheme: textTheme,
      ),
      const Divider(height: 28),
      _CardRow(
        label: 'Şehir / ülke',
        value: b.cityCountry.isEmpty ? '—' : b.cityCountry,
        textTheme: textTheme,
      ),
      if (b.professionalTags.isNotEmpty) ...[
        const Divider(height: 28),
        Text(
          'Professional tags',
          style: textTheme.labelLarge?.copyWith(
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: b.professionalTags
              .map(
                (t) => Chip(
                  label: Text(t),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ],
      if (b.lookingFor.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(
          'Aradığı',
          style: textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: b.lookingFor
              .map(
                (t) => Chip(
                  label: Text(t),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ],
      if (b.elevatorPitch.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(
          'Bio / elevator pitch',
          style: textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        _InfoBox(text: b.elevatorPitch, textTheme: textTheme),
      ],
    ];
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
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
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text, required this.textTheme});

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.vexa.scaffold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.vexa.border),
      ),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }
}
