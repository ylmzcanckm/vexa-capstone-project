import 'package:flutter/material.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/finder/presentation/vexa_finder_alert_screen.dart';
import 'package:vexa/features/matching/presentation/match_compass_palette.dart';
import 'package:vexa/features/matching/presentation/screens/match_candidates_screen.dart';

/// Yakınlık / eşleşme anı — telefon uyarısı + (donanım hazır olunca) LilyGO titreşimi.
final class VexaFinderService {
  const VexaFinderService._();

  /// Tam ekran mavi-mor uyarı + telefon haptics.
  static Future<bool?> showProximityAlert(
    BuildContext context, {
    String? subtitle,
    bool exploreOnAccept = true,
  }) async {
    await pulseDeviceIfPossible();

    if (!context.mounted) return null;
    return Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        fullscreenDialog: true,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (ctx, animation, secondary) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: VexaFinderAlertScreen(
              subtitle: subtitle,
              onExplore: exploreOnAccept
                  ? () {
                      Navigator.of(ctx).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const MatchCandidatesScreen(),
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Demo — yalnızca uyarı ekranını gösterir; eşleşme pop-up'ı açmaz.
  static Future<void> simulateProximityMatch(BuildContext context) async {
    await showProximityAlert(
      context,
      subtitle:
          'Demo: Gerçek eşleşme yalnızca LilyGO bağlıyken, Finder açıkken '
          've yakında VEXA algılandığında tetiklenir.',
      exploreOnAccept: false,
    );
  }

  /// LilyGO'ya Finder pulse (`0x05`) gönderir — iki kısa güçlü titreşim.
  static Future<void> pulseDeviceIfPossible() async {
    if (!BleAvatarTransferService.isSupported) return;
    try {
      final ble = BleAvatarTransferService();
      await ble.scanConnectAndPulse();
    } catch (_) {
      // Motor / BLE yoksa yalnızca telefon haptics yeterli.
    }
  }

  /// Eşleşme daveti anında LilyGO'ya QUIZ TIME (`0x06`) — pop-up'tan önce çağrılır.
  static Future<void> quizTimeSignalIfPossible() async {
    if (!BleAvatarTransferService.isSupported) return;
    try {
      final ble = BleAvatarTransferService();
      await ble.scanConnectAndQuizTime();
    } catch (_) {
      // Motor / BLE yoksa yalnızca telefon haptics yeterli.
    }
  }

  /// Quiz ≥ %80: LilyGO arcade ok ekranı (`0x07`).
  static Future<void> arcadeCompassSignalIfPossible({
    required String matchId,
    required String myUserId,
    required String partnerUserId,
  }) async {
    if (!BleAvatarTransferService.isSupported) return;
    try {
      final colorIndex = MatchCompassPalette.colorIndexFor(matchId);
      final arrowRight = myUserId.compareTo(partnerUserId) < 0;
      final ble = BleAvatarTransferService();
      await ble.scanConnectAndArcadeCompass(
        colorIndex: colorIndex,
        arrowRight: arrowRight,
      );
    } catch (_) {
      // Firmware henüz 0x07 desteklemiyorsa telefon ekranı yine açılır.
    }
  }
}
