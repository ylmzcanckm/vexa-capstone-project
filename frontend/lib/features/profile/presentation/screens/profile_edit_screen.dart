import 'package:flutter/material.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/core/utils/user_age.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';
import 'package:vexa/features/mode/presentation/widgets/business_profile_completion_section.dart';
import 'package:vexa/features/mode/presentation/widgets/social_profile_completion_section.dart';

/// [editScope]: hangi moddan açıldıysa o alanlar düzenlenir (Ghost → isim/soyisim/doğum).
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.editScope});

  final VexaMode editScope;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _ghostFormKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _ageReadOnly = TextEditingController();
  DateTime? _ghostBirth;
  final GlobalKey<SocialProfileEditorState> _socialKey =
      GlobalKey<SocialProfileEditorState>();
  final GlobalKey<BusinessProfileEditorState> _businessKey =
      GlobalKey<BusinessProfileEditorState>();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await UserProfileStore.load();
    if (!mounted) return;
    if (p != null) {
      _name.text = p.name;
      _surname.text = p.surname;
      _ghostBirth = UserAge.tryParseIsoDate(p.birthDateIso);
      _ageReadOnly.text = UserAge.displayAgeAndBirth(p.birthDateIso);
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _ageReadOnly.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu' : null;

  InputDecoration _dec(String? label, {bool readOnly = false}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: readOnly
          ? context.vexa.scaffold
          : context.vexa.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _pickGhostBirth() async {
    final now = DateTime.now();
    final initial = _ghostBirth ?? DateTime(now.year - 22, 7, 1);
    final first = DateTime(now.year - 120);
    final last = DateTime(now.year - 13, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first)
          ? first
          : initial.isAfter(last)
              ? last
              : initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Doğum tarihi',
    );
    if (picked != null) {
      setState(() => _ghostBirth = picked);
    }
  }

  Future<void> _saveGhost() async {
    if (_ghostBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğum tarihi seç.')),
      );
      return;
    }
    if (!UserAge.isValidOnboardingBirth(_ghostBirth!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yaş 13–120 aralığında olmalı.')),
      );
      return;
    }
    if (!_ghostFormKey.currentState!.validate()) return;
    final p = await UserProfileStore.load();
    if (!mounted) return;
    await UserProfileStore.save(
      (p ?? const StoredUserProfile(name: '', surname: '', birthDateIso: ''))
          .copyWith(
        name: _name.text.trim(),
        surname: _surname.text.trim(),
        birthDateIso: UserAge.toIsoDateOnly(_ghostBirth!),
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _saveSocial() async {
    final ok = await _socialKey.currentState?.persist(context) ?? false;
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _saveBusiness() async {
    final ok = await _businessKey.currentState?.persist() ?? false;
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _onAppBarSave() async {
    await switch (widget.editScope) {
      VexaMode.ghost => _saveGhost(),
      VexaMode.social => _saveSocial(),
      VexaMode.business => _saveBusiness(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isGhost = widget.editScope == VexaMode.ghost;
    final readOnlyCore = !isGhost;
    final ghostBirthLabel = _ghostBirth == null
        ? 'Doğum tarihi seç'
        : '${UserAge.formatTrDayMonthYear(_ghostBirth!)} '
            '(${UserAge.completedYears(UserAge.toIsoDateOnly(_ghostBirth!))} yaşında)';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGhost
              ? 'Profili düzenle'
              : widget.editScope == VexaMode.social
                  ? 'Sosyal profili düzenle'
                  : 'Network profilini düzenle',
        ),
        actions: [
          TextButton(
            onPressed: _onAppBarSave,
            child: const Text(
              'Kaydet',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            readOnlyCore
                ? 'İsim, soyisim ve doğum bilgisi onboarding’de kayıtlı; burada salt okunur.'
                : 'Temel bilgilerini güncelle.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (isGhost)
            Form(
              key: _ghostFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: _dec('İsim'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _surname,
                    decoration: _dec('Soyisim'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Doğum tarihi',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: _pickGhostBirth,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(ghostBirthLabel),
                  ),
                ],
              ),
            )
          else ...[
            TextFormField(
              controller: _name,
              readOnly: true,
              decoration: _dec('İsim', readOnly: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _surname,
              readOnly: true,
              decoration: _dec('Soyisim', readOnly: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ageReadOnly,
              readOnly: true,
              decoration: _dec('Yaş (hesaplanan)', readOnly: true),
            ),
            const SizedBox(height: 24),
            if (widget.editScope == VexaMode.social)
              SocialProfileEditor(key: _socialKey, showInlineSave: false)
            else
              BusinessProfileEditor(key: _businessKey, showInlineSave: false),
          ],
        ],
      ),
    );
  }
}
