import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/core/utils/user_age.dart';

/// Sosyal modda doldurulan alanlar (tanışma + filtrelerle uyumlu).
final class SocialProfileData {
  const SocialProfileData({
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.education,
    required this.interestIds,
    this.tobacco,
    this.alcohol,
    this.aboutMe,
    this.randomSkill,
  });

  final String heightCm;
  final String weightKg;
  final String gender;
  final String education;
  final List<String> interestIds;
  final String? tobacco;
  final String? alcohol;
  final String? aboutMe;
  final String? randomSkill;

  Map<String, dynamic> toJson() => {
        'heightCm': heightCm,
        'weightKg': weightKg,
        'gender': gender,
        'education': education,
        'interestIds': interestIds,
        'tobacco': tobacco,
        'alcohol': alcohol,
        'aboutMe': aboutMe,
        'randomSkill': randomSkill,
      };

  factory SocialProfileData.fromJson(Map<String, dynamic> j) {
    return SocialProfileData(
      heightCm: j['heightCm'] as String? ?? '',
      weightKg: j['weightKg'] as String? ?? '',
      gender: j['gender'] as String? ?? '',
      education: j['education'] as String? ?? '',
      interestIds: (j['interestIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tobacco: j['tobacco'] as String?,
      alcohol: j['alcohol'] as String?,
      aboutMe: j['aboutMe'] as String?,
      randomSkill: j['randomSkill'] as String?,
    );
  }

  SocialProfileData copyWith({
    String? heightCm,
    String? weightKg,
    String? gender,
    String? education,
    List<String>? interestIds,
    String? tobacco,
    String? alcohol,
    String? aboutMe,
    String? randomSkill,
  }) {
    return SocialProfileData(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      education: education ?? this.education,
      interestIds: interestIds ?? this.interestIds,
      tobacco: tobacco ?? this.tobacco,
      alcohol: alcohol ?? this.alcohol,
      aboutMe: aboutMe ?? this.aboutMe,
      randomSkill: randomSkill ?? this.randomSkill,
    );
  }
}

/// Network modu kimlik kartı + professional tags + looking for + bio.
final class BusinessProfileData {
  const BusinessProfileData({
    required this.jobTitle,
    required this.companyOrUniversity,
    required this.departmentOrField,
    required this.cityCountry,
    this.workStatus,
    this.professionalTags = const [],
    this.lookingFor = const [],
    required this.elevatorPitch,
    this.hardSkills = const [],
    this.linkedinUrl,
    this.workEmail,
    this.networkPhotoPath,
  });

  final String jobTitle;
  final String companyOrUniversity;
  final String departmentOrField;
  final String cityCountry;
  final String? workStatus;
  final List<String> professionalTags;
  final List<String> lookingFor;
  final String elevatorPitch;
  /// Geriye dönük JSON alanı; yeni kayıtlarda boş liste.
  final List<String> hardSkills;
  final String? linkedinUrl;
  final String? workEmail;

  /// Uygulama dizininde kayıtlı ağ profili fotoğrafı (yerel dosya yolu).
  final String? networkPhotoPath;

  Map<String, dynamic> toJson() => {
        'bv': 3,
        'jobTitle': jobTitle,
        'companyOrUniversity': companyOrUniversity,
        'departmentOrField': departmentOrField,
        'cityCountry': cityCountry,
        'workStatus': workStatus,
        'professionalTags': professionalTags,
        'lookingFor': lookingFor,
        'elevatorPitch': elevatorPitch,
        'hardSkills': hardSkills,
        'linkedinUrl': linkedinUrl,
        'workEmail': workEmail,
        'networkPhotoPath': networkPhotoPath,
      };

  factory BusinessProfileData.fromJson(Map<String, dynamic> j) {
    final isNew = j['bv'] == 2 ||
        j['bv'] == 3 ||
        j.containsKey('elevatorPitch') ||
        j.containsKey('companyOrUniversity');
    if (isNew) {
      return BusinessProfileData(
        jobTitle: j['jobTitle'] as String? ?? '',
        companyOrUniversity: j['companyOrUniversity'] as String? ??
            j['companyName'] as String? ??
            '',
        departmentOrField: j['departmentOrField'] as String? ??
            j['industry'] as String? ??
            '',
        cityCountry: j['cityCountry'] as String? ?? '',
        workStatus: j['workStatus'] as String?,
        professionalTags: (j['professionalTags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        lookingFor: (j['lookingFor'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        elevatorPitch: j['elevatorPitch'] as String? ??
            j['summary'] as String? ??
            '',
        hardSkills: (j['hardSkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        linkedinUrl: j['linkedinUrl'] as String?,
        workEmail: j['workEmail'] as String?,
        networkPhotoPath: j['networkPhotoPath'] as String?,
      );
    }
    return BusinessProfileData(
      jobTitle: j['jobTitle'] as String? ?? '',
      companyOrUniversity: j['companyName'] as String? ?? '',
      departmentOrField: j['industry'] as String? ?? '',
      cityCountry: '',
      workStatus: null,
      professionalTags: const [],
      lookingFor: const [],
      elevatorPitch: j['summary'] as String? ?? '',
      hardSkills: const [],
      linkedinUrl: j['linkedinUrl'] as String?,
      workEmail: j['workEmail'] as String?,
      networkPhotoPath: null,
    );
  }

  BusinessProfileData copyWith({
    String? jobTitle,
    String? companyOrUniversity,
    String? departmentOrField,
    String? cityCountry,
    String? workStatus,
    List<String>? professionalTags,
    List<String>? lookingFor,
    String? elevatorPitch,
    List<String>? hardSkills,
    String? linkedinUrl,
    String? workEmail,
    String? networkPhotoPath,
    bool clearNetworkPhoto = false,
  }) {
    return BusinessProfileData(
      jobTitle: jobTitle ?? this.jobTitle,
      companyOrUniversity: companyOrUniversity ?? this.companyOrUniversity,
      departmentOrField: departmentOrField ?? this.departmentOrField,
      cityCountry: cityCountry ?? this.cityCountry,
      workStatus: workStatus ?? this.workStatus,
      professionalTags: professionalTags ?? this.professionalTags,
      lookingFor: lookingFor ?? this.lookingFor,
      elevatorPitch: elevatorPitch ?? this.elevatorPitch,
      hardSkills: hardSkills ?? this.hardSkills,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      workEmail: workEmail ?? this.workEmail,
      networkPhotoPath:
          clearNetworkPhoto ? null : (networkPhotoPath ?? this.networkPhotoPath),
    );
  }
}

/// Çekirdek: isim, soyisim, doğum tarihi (ISO gün). [avatarSeed] DiceBear Dylan için.
final class StoredUserProfile {
  const StoredUserProfile({
    required this.name,
    required this.surname,
    required this.birthDateIso,
    this.avatarSeed = '',
    this.social,
    this.business,
  });

  final String name;
  final String surname;
  /// `YYYY-MM-DD`
  final String birthDateIso;
  /// DiceBear `seed`; boşsa profil kartında baş harf kullanılır.
  final String avatarSeed;
  final SocialProfileData? social;
  final BusinessProfileData? business;

  Map<String, dynamic> toJson() => {
        'v': 2,
        'name': name,
        'surname': surname,
        'birthDateIso': birthDateIso,
        'avatarSeed': avatarSeed,
        'social': social?.toJson(),
        'business': business?.toJson(),
      };

  factory StoredUserProfile.fromJson(Map<String, dynamic> j) {
    final v = j['v'] as int? ?? 1;
    if (v >= 2) {
      final iso = j['birthDateIso'] as String? ?? '';
      final migrated = iso.isNotEmpty
          ? iso
          : UserAge.legacyIsoFromAgeString(j['age'] as String? ?? '');
      return StoredUserProfile(
        name: j['name'] as String? ?? '',
        surname: j['surname'] as String? ?? '',
        birthDateIso: migrated,
        avatarSeed: j['avatarSeed'] as String? ?? '',
        social: j['social'] is Map<String, dynamic>
            ? SocialProfileData.fromJson(j['social'] as Map<String, dynamic>)
            : null,
        business: j['business'] is Map<String, dynamic>
            ? BusinessProfileData.fromJson(j['business'] as Map<String, dynamic>)
            : null,
      );
    }
    return StoredUserProfile(
      name: j['name'] as String? ?? '',
      surname: j['surname'] as String? ?? '',
      birthDateIso: '',
      avatarSeed: '',
      social: SocialProfileData(
        heightCm: j['heightCm'] as String? ?? '',
        weightKg: j['weightKg'] as String? ?? '',
        gender: j['gender'] as String? ?? '',
        education: j['education'] as String? ?? '',
        interestIds: (j['interestIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        tobacco: j['tobacco'] as String?,
        alcohol: j['alcohol'] as String?,
        aboutMe: j['aboutMe'] as String?,
        randomSkill: j['randomSkill'] as String?,
      ),
    );
  }

  StoredUserProfile copyWith({
    String? name,
    String? surname,
    String? birthDateIso,
    String? avatarSeed,
    SocialProfileData? social,
    BusinessProfileData? business,
    bool clearSocial = false,
    bool clearBusiness = false,
  }) {
    return StoredUserProfile(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDateIso: birthDateIso ?? this.birthDateIso,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      social: clearSocial ? null : (social ?? this.social),
      business: clearBusiness ? null : (business ?? this.business),
    );
  }
}

final class UserProfileStore {
  const UserProfileStore._();

  static const _key = 'vexa_user_profile_v1';

  static Future<void> save(StoredUserProfile p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(p.toJson()));
  }

  static Future<StoredUserProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return StoredUserProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
