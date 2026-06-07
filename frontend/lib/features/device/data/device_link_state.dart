/// Sunucu + yerel cihaz eşleme durumu (ayarlar / yönlendirme).
final class DeviceLinkState {
  const DeviceLinkState({
    required this.hasServerPair,
    this.deviceCode,
    this.deviceName,
  });

  final bool hasServerPair;
  final String? deviceCode;
  final String? deviceName;

  static DeviceLinkState fromServer(Map<String, dynamic>? data) {
    if (data == null) {
      return const DeviceLinkState(hasServerPair: false);
    }
    final device = data['device'] as Map<String, dynamic>?;
    final pairing = data['pairing'] as Map<String, dynamic>?;
    final code = (device?['deviceCode'] as String?)?.trim();
    final name = (device?['deviceName'] as String?)?.trim();
    final hasPair = pairing != null || (code != null && code.isNotEmpty);
    return DeviceLinkState(
      hasServerPair: hasPair,
      deviceCode: code,
      deviceName: name,
    );
  }

  bool get isSimulation =>
      deviceCode != null && deviceCode!.toUpperCase().startsWith('VEXA-SIM');

  bool get isBleHardware =>
      deviceCode != null &&
      (deviceCode!.toUpperCase().contains('VEXA-B') ||
          deviceCode!.toUpperCase().startsWith('BLE-') ||
          deviceCode!.toUpperCase() == 'VEXA-B4DC');

  /// Ayarlarda “gerçek LilyGO bağlı” gösterimi.
  bool get isLiveBlePaired => hasServerPair && isBleHardware && !isSimulation;

  String get settingsSummary {
    if (!hasServerPair) {
      return 'Bağlı değil — LilyGO eşlemesi yapılmadı.';
    }
    if (isSimulation) {
      return 'Simülasyon kaydı ($deviceCode). Gerçek LilyGO değil.';
    }
    if (isBleHardware) {
      return 'LilyGO eşlendi: ${deviceName ?? deviceCode}';
    }
    return 'Sunucuda kayıt: ${deviceName ?? deviceCode ?? "—"}';
  }
}
