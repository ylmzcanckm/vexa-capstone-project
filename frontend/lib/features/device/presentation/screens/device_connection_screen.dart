import 'package:flutter/material.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/mode/presentation/screens/mode_selection_screen.dart';
import 'package:vexa/features/profile/presentation/screens/profile_creation_screen.dart';

/// Google / Apple sonrası zorunlu cihaz eşlemesi (şimdilik simülasyon; atlanamaz).
class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({
    super.key,
    required this.loginScreenBuilder,
  });

  /// Girişe dönüş için (login modülünü import etmeyelim — döngü önlenir).
  final Widget Function() loginScreenBuilder;

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  bool _busy = false;

  Future<void> _simulateConnect() async {
    setState(() => _busy = true);
    await DeviceConnectionPreferences.setLinked(true);
    final onboarded = await OnboardingPreferences.isComplete();
    if (!mounted) return;
    setState(() => _busy = false);
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => onboarded
            ? const ModeSelectionScreen()
            : const ProfileCreationScreen(),
      ),
    );
  }

  void _backToLogin() {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(builder: (_) => widget.loginScreenBuilder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vexa = context.vexa;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: vexa.scaffold,
        appBar: AppBar(
          title: const Text('Cihaz bağlantısı'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: vexa.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: vexa.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bluetooth_searching_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'VEXA cihazını bağla',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Uygulama, giyilebilir donanım ile eşleşmeden devam edemez. '
                          'Donanım yazılımı hazır olunca burada gerçek BLE taraması ve '
                          'eşleştirme adımları olacak.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: vexa.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: vexa.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: vexa.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.accent,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Şu an yalnızca yer tutucu ekran: aşağıdaki düğme '
                                  'bağlantıyı simüle eder ve akışa devam eder.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: vexa.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _busy ? null : _simulateConnect,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Cihazı bağla (simülasyon)',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy ? null : _backToLogin,
                  child: const Text('Giriş ekranına dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
