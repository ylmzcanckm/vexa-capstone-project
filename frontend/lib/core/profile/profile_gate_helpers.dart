import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';

bool isSocialProfileComplete(SocialProfileData? s) {
  if (s == null) return false;
  if (s.heightCm.trim().isEmpty || s.weightKg.trim().isEmpty) return false;
  if (s.gender.trim().isEmpty) return false;
  if (s.education.trim().isEmpty) return false;
  if (s.tobacco == null || s.alcohol == null) return false;
  final n = s.interestIds.length;
  if (n < MatchInterest.minSelection || n > MatchInterest.maxSelection) {
    return false;
  }
  return true;
}

bool isBusinessProfileComplete(BusinessProfileData? b) {
  if (b == null) return false;
  if (b.jobTitle.trim().isEmpty) return false;
  if (b.companyOrUniversity.trim().isEmpty) return false;
  if (b.departmentOrField.trim().isEmpty) return false;
  if (b.cityCountry.trim().isEmpty) return false;
  if (b.workStatus == null || b.workStatus!.trim().isEmpty) return false;
  if (b.professionalTags.isEmpty) return false;
  if (b.lookingFor.isEmpty) return false;
  if (b.elevatorPitch.trim().isEmpty) return false;
  return true;
}
