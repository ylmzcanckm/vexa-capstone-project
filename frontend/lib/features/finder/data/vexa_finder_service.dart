import 'package:flutter/material.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/finder/presentation/vexa_finder_alert_screen.dart';
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

  /// Demo / test — gerçek BLE yakınlık olayı gelince buradan tetiklenecek.
  static Future<void> simulateProximityMatch(BuildContext context) async {
    await showProximityAlert(
      context,
      subtitle:
          'Demo: Gerçek sürümde LilyGO titreşir ve bu ekran otomatik açılır.',
    );
  }

  /// LilyGO'ya Finder pulse (`0x05`) gönderir — iki kısa güçlü titreşim.
  ///
  /// Firmware `0x06` (QUIZ TIME yazısı + titreşim) komutunu alınca
  /// eşleşme davetinde ona geçilecek.
  static Future<void> pulseDeviceIfPossible() async {
    if (!BleAvatarTransferService.isSupported) return;
    try {
      final ble = BleAvatarTransferService();
      await ble.scanConnectAndPulse();
    } catch (_) {
      // Motor / BLE yoksa yalnızca telefon haptics yeterli.
    }
  }
}
