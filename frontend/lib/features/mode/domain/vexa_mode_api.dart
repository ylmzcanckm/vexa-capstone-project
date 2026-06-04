import 'package:vexa/features/mode/domain/vexa_mode.dart';

/// Flutter modları ↔ backend `selected_mode` (`social` | `networking`).
extension VexaModeApi on VexaMode {
  /// Ghost backend'de yok; API'ye yazılmaz.
  String? get backendMode => switch (this) {
        VexaMode.social => 'social',
        VexaMode.business => 'networking',
        VexaMode.ghost => null,
      };

  static VexaMode? fromBackend(String? mode) => switch (mode) {
        'social' => VexaMode.social,
        'networking' => VexaMode.business,
        _ => null,
      };
}
