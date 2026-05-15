import 'package:flutter/material.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/core/utils/user_age.dart';
import 'package:vexa/features/onboarding/presentation/screens/avatar_selection_screen.dart';

/// Onboarding: isim, soyisim, doğum tarihi (gün/ay/yıl). Yaş hesaplanarak gösterilir.
class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  DateTime? _birthDate;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 22, now.month, now.day);
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
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _onSubmit() async {
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğum tarihi seç.')),
      );
      return;
    }
    if (!UserAge.isValidOnboardingBirth(_birthDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yaş 13–120 aralığında olmalı.')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final existing = await UserProfileStore.load();
    final iso = UserAge.toIsoDateOnly(_birthDate!);
    final profile = StoredUserProfile(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      birthDateIso: iso,
      avatarSeed: existing?.avatarSeed ?? '',
      social: existing?.social,
      business: existing?.business,
    );
    await UserProfileStore.save(profile);
    try {
      await UserRepository.pushProfile(profile);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil sunucuya kaydedilemedi: ${e.message}')),
      );
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sunucuya bağlanılamadı. Yerel kayıt yapıldı; tekrar dene.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const AvatarSelectionScreen(),
      ),
    );
  }

  String? _requiredTextValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur.';
    }
    return null;
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: context.vexa.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.vexa.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.vexa.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final birthLabel = _birthDate == null
        ? 'Doğum tarihi seç'
        : '${UserAge.formatTrDayMonthYear(_birthDate!)} '
            '(${UserAge.completedYears(UserAge.toIsoDateOnly(_birthDate!))} yaşında)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Oluştur'),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Kendini Tanıt', style: textTheme.headlineLarge),
                const SizedBox(height: 10),
                Container(
                  height: 3,
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: AppColors.brandGradient,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Önce temel bilgilerini alıyoruz. Sosyal veya network profilini mod seçtikten sonra tamamlayacaksın.',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                _InputField(
                  label: 'İsim',
                  hintText: 'Adını gir',
                  controller: _nameController,
                  validator: _requiredTextValidator,
                  decoration: _inputDecoration(context),
                ),
                const SizedBox(height: 14),
                _InputField(
                  label: 'Soyisim',
                  hintText: 'Soyadını gir',
                  controller: _surnameController,
                  validator: _requiredTextValidator,
                  decoration: _inputDecoration(context),
                ),
                const SizedBox(height: 14),
                _SectionTitle(title: 'Doğum tarihi (gün / ay / yıl)'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickBirthDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(birthLabel),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _GradientSubmitButton(
                  isSubmitting: _submitting,
                  onPressed: _submitting ? null : _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.decoration,
    this.validator,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final InputDecoration decoration;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: decoration.copyWith(hintText: hintText),
        ),
      ],
    );
  }
}

class _GradientSubmitButton extends StatelessWidget {
  const _GradientSubmitButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
            ),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: Center(
                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Devam Et',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.vexa.textPrimary,
      ),
    );
  }
}
