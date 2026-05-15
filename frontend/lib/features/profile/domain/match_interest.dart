import 'package:flutter/foundation.dart';

/// Eşleşme hiyerarşisinde 2. katman: demografik filtrelerden (boy, kilo, eğitim)
/// sonra kullanılacak ilgi alanları. İleride yakınlık (ör. ~15 m) + %80 quiz
/// akışında aynı [id] değerleri referans alınmalıdır.
@immutable
final class MatchInterest {
  const MatchInterest({
    required this.id,
    required this.label,
    required this.emoji,
  });

  /// API / quiz / bildirim katmanında kullanılacak sabit anahtar (İngilizce).
  final String id;

  /// Standart Türkçe görünen ad (emoji hariç).
  final String label;

  final String emoji;

  String get displayLabel => '$emoji $label';

  /// Fotoğraftaki kategorilerle birebir hizalı, standart isimlendirme.
  static const List<MatchInterest> catalog = [
    MatchInterest(id: 'sport', label: 'Spor & fitness', emoji: '🏃'),
    MatchInterest(id: 'food', label: 'Yemek & gastronomi', emoji: '🍽️'),
    MatchInterest(id: 'tech', label: 'Teknoloji', emoji: '💻'),
    MatchInterest(
      id: 'screen_media',
      label: 'Sinema, dizi & anime',
      emoji: '🎬',
    ),
    MatchInterest(id: 'books', label: 'Kitap & okuma', emoji: '📚'),
    MatchInterest(id: 'outdoor', label: 'Kamp & doğa', emoji: '⛺'),
    MatchInterest(id: 'fashion', label: 'Moda', emoji: '👗'),
    MatchInterest(id: 'art', label: 'Sanat', emoji: '🎨'),
    MatchInterest(id: 'gaming', label: 'Oyun', emoji: '🎮'),
    MatchInterest(id: 'music', label: 'Müzik', emoji: '🎵'),
  ];

  static MatchInterest? byId(String id) {
    for (final i in catalog) {
      if (i.id == id) return i;
    }
    return null;
  }

  static const int minSelection = 1;
  static const int maxSelection = 3;
}
