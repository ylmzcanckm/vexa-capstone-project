import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vexa/core/constants/business_network_catalog.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';

/// Network modu: kimlik kartı, sektör sekmeli tag’ler, arayış, bio.
class BusinessProfileEditor extends StatefulWidget {
  const BusinessProfileEditor({
    super.key,
    this.showInlineSave = false,
  });

  final bool showInlineSave;

  @override
  BusinessProfileEditorState createState() => BusinessProfileEditorState();
}

class BusinessProfileEditorState extends State<BusinessProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _jobTitle;
  late final TextEditingController _company;
  late final TextEditingController _department;
  late final TextEditingController _cityCountry;
  late final TextEditingController _elevator;
  late final TextEditingController _linkedin;
  late final TextEditingController _workEmail;

  String? _workStatus;
  final Set<String> _professionalTags = {};
  final Set<String> _lookingFor = {};
  String? _networkPhotoPath;

  String _coreFirstName = '';
  String _coreSurname = '';

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _jobTitle = TextEditingController();
    _company = TextEditingController();
    _department = TextEditingController();
    _cityCountry = TextEditingController();
    _elevator = TextEditingController();
    _linkedin = TextEditingController();
    _workEmail = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final p = await UserProfileStore.load();
    final b = p?.business;
    if (!mounted) return;
    _coreFirstName = p?.name ?? '';
    _coreSurname = p?.surname ?? '';
    if (b != null) {
      _jobTitle.text = b.jobTitle;
      _company.text = b.companyOrUniversity;
      _department.text = b.departmentOrField;
      _cityCountry.text = b.cityCountry;
      _elevator.text = b.elevatorPitch;
      _linkedin.text = b.linkedinUrl ?? '';
      _workEmail.text = b.workEmail ?? '';
      _workStatus = b.workStatus;
      _networkPhotoPath = b.networkPhotoPath;
      _professionalTags
        ..clear()
        ..addAll(b.professionalTags);
      _lookingFor
        ..clear()
        ..addAll(b.lookingFor);
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _jobTitle.dispose();
    _company.dispose();
    _department.dispose();
    _cityCountry.dispose();
    _elevator.dispose();
    _linkedin.dispose();
    _workEmail.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu' : null;

  String? _linkedinValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) return 'Geçerli bir adres gir';
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'http veya https';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
    return ok ? null : 'Geçerli e-posta gir';
  }

  Future<void> _pickNetworkPhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 88,
    );
    if (x == null || !mounted) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      var ext = '.jpg';
      final lp = x.path.toLowerCase();
      if (lp.endsWith('.png')) ext = '.png';
      if (lp.endsWith('.webp')) ext = '.webp';
      final out = File('${dir.path}/vexa_network_${DateTime.now().millisecondsSinceEpoch}$ext');
      await out.writeAsBytes(await x.readAsBytes());
      final prev = _networkPhotoPath;
      if (prev != null && prev != out.path) {
        final o = File(prev);
        if (o.existsSync()) await o.delete();
      }
      setState(() => _networkPhotoPath = out.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf kaydedilemedi: $e')),
      );
    }
  }

  void _removeNetworkPhoto() {
    final prev = _networkPhotoPath;
    if (prev != null) {
      final o = File(prev);
      if (o.existsSync()) {
        try {
          o.deleteSync();
        } catch (_) {}
      }
    }
    setState(() => _networkPhotoPath = null);
  }

  bool _validateLists(BuildContext context) {
    if (_workStatus == null || _workStatus!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çalışma durumu seç.')),
      );
      return false;
    }
    _professionalTags.removeWhere((t) => !kAllProfessionalCatalogTags.contains(t));
    if (_professionalTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir professional tag seç.')),
      );
      return false;
    }
    if (_lookingFor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('“Currently looking for” için en az bir seçim yap.')),
      );
      return false;
    }
    return true;
  }

  Future<bool> persist() async {
    if (!_validateLists(context)) return false;
    if (!_formKey.currentState!.validate()) return false;
    setState(() => _saving = true);
    final existing = await UserProfileStore.load();
    if (!mounted) return false;
    final core = existing ??
        const StoredUserProfile(name: '', surname: '', birthDateIso: '');
    final business = BusinessProfileData(
      jobTitle: _jobTitle.text.trim(),
      companyOrUniversity: _company.text.trim(),
      departmentOrField: _department.text.trim(),
      cityCountry: _cityCountry.text.trim(),
      workStatus: _workStatus,
      professionalTags: _professionalTags.toList()..sort(),
      lookingFor: _lookingFor.toList()..sort(),
      elevatorPitch: _elevator.text.trim(),
      hardSkills: const [],
      linkedinUrl: _linkedin.text.trim().isEmpty ? null : _linkedin.text.trim(),
      workEmail: _workEmail.text.trim().isEmpty ? null : _workEmail.text.trim(),
      networkPhotoPath: _networkPhotoPath,
    );
    await UserProfileStore.save(core.copyWith(business: business));
    if (!mounted) return false;
    setState(() => _saving = false);
    return true;
  }

  Future<void> _saveInline() async {
    final ok = await persist();
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network profili kaydedildi.')),
      );
    }
  }

  InputDecoration _dec(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: context.vexa.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  TextStyle _sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.w800,
            color: context.vexa.textPrimary,
          );

  Widget _photoAvatar(double radius, TextTheme textTheme) {
    final path = _networkPhotoPath;
    if (path != null && File(path).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(path)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Icon(Icons.add_a_photo_outlined, size: radius * 1.1, color: AppColors.primary),
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
    final industryKeys = kProfessionalTagsByIndustry.keys.toList();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showInlineSave) ...[
            Text(
              'Network modu kimlik kartı',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.vexa.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ağ profilinde DiceBear avatarı kullanılmaz; galeriden fotoğraf yükleyebilirsin.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
          ],
          Text('1. Temel kimlik', style: _sectionTitle(context)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _photoAvatar(36, textTheme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil fotoğrafı',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _pickNetworkPhoto,
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Galeriden seç'),
                        ),
                        if (_networkPhotoPath != null)
                          TextButton(
                            onPressed: _removeNetworkPhoto,
                            child: const Text('Kaldır'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ad Soyad',
                      style: textTheme.labelMedium?.copyWith(
                        color: context.vexa.textSecondary,
                      ),
                    ),
                    Text(
                      '${_coreFirstName.trim()} ${_coreSurname.trim()}'.trim().isEmpty
                          ? '—'
                          : '${_coreFirstName.trim()} ${_coreSurname.trim()}'.trim(),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _jobTitle,
            decoration: _dec(context, 'Ünvan'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _company,
            decoration: _dec(context, 'Şirket / Üniversite'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _department,
            decoration: _dec(context, 'Bölüm / alan'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityCountry,
            decoration: _dec(context, 'Şehir / ülke'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          Text('Çalışma durumu', style: textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _workStatus,
            hint: const Text('Seç'),
            items: kNetworkWorkStatusLabels
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _workStatus = v),
            validator: (v) => v == null || v.isEmpty ? 'Seç' : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.vexa.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '2. Professional tags',
            style: _sectionTitle(context),
          ),
          const SizedBox(height: 4),
          Text(
            'İş kolu sekmesinden etiket seç; birden fazla sekmenden seçebilirsin.',
            style: textTheme.bodySmall?.copyWith(color: context.vexa.textSecondary),
          ),
          const SizedBox(height: 10),
          DefaultTabController(
            length: industryKeys.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: context.vexa.textSecondary,
                  indicatorColor: AppColors.accent,
                  tabs: [
                    for (final k in industryKeys)
                      Tab(
                        child: Text(
                          k,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 240,
                  child: TabBarView(
                    children: [
                      for (final cat in industryKeys)
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (kProfessionalTagsByIndustry[cat] ?? const [])
                                .map((tag) {
                              final on = _professionalTags.contains(tag);
                              return FilterChip(
                                label: Text(tag),
                                selected: on,
                                onSelected: (sel) {
                                  setState(() {
                                    if (sel) {
                                      _professionalTags.add(tag);
                                    } else {
                                      _professionalTags.remove(tag);
                                    }
                                  });
                                },
                                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                                checkmarkColor: AppColors.primary,
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '3. Currently looking for',
            style: _sectionTitle(context),
          ),
          const SizedBox(height: 4),
          Text(
            'Ne aradığını seç; sohbeti başlatır.',
            style: textTheme.bodySmall?.copyWith(color: context.vexa.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kLookingForLabels.map((tag) {
              final on = _lookingFor.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: on,
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _lookingFor.add(tag);
                    } else {
                      _lookingFor.remove(tag);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            '4. Bio / elevator pitch',
            style: _sectionTitle(context),
          ),
          const SizedBox(height: 4),
          Text(
            'Kısa tut (maks. birkaç satır).',
            style: textTheme.bodySmall?.copyWith(color: context.vexa.textSecondary),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _elevator,
            maxLines: 3,
            minLines: 2,
            maxLength: kElevatorPitchMaxLength,
            decoration: _dec(context, 'Kendini 2–3 cümleyle anlat').copyWith(
              counterText: '',
            ),
            validator: _required,
          ),
          const SizedBox(height: 20),
          Text('İsteğe bağlı', style: _sectionTitle(context)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _linkedin,
            decoration: _dec(context, 'LinkedIn'),
            validator: _linkedinValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _workEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: _dec(context, 'İş e-postası'),
            validator: _emailValidator,
          ),
          if (widget.showInlineSave) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _saveInline,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Network profilini kaydet'),
            ),
          ],
        ],
      ),
    );
  }
}

class BusinessProfileCompletionSection extends StatelessWidget {
  const BusinessProfileCompletionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const BusinessProfileEditor(showInlineSave: true);
  }
}
