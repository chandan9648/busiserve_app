import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';

/// Covers the current route while the device has no working internet access.
/// A failed reachability probe is retried automatically, so the user's route
/// is restored as soon as internet access returns.
class OfflineGate extends StatefulWidget {
  const OfflineGate({super.key, required this.child});
  final Widget child;

  @override
  State<OfflineGate> createState() => _OfflineGateState();
}

class _OfflineGateState extends State<OfflineGate> with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _poll;
  bool _isOffline = false;
  bool _checking = false;
  bool _hasChecked = false;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb) {
      _subscription =
          Connectivity().onConnectivityChanged.listen((_) => _checkInternet());
      _poll =
          Timer.periodic(const Duration(seconds: 5), (_) => _checkInternet());
      _checkInternet();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkInternet();
  }

  Future<void> _checkInternet() async {
    if (_checking || !mounted || kIsWeb) return;
    _checking = true;
    var online = false;
    try {
      final results = await Connectivity()
          .checkConnectivity()
          .timeout(const Duration(seconds: 3));
      if (results.any((result) => result != ConnectivityResult.none)) {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 4);
        try {
          final request = await client
              .getUrl(Uri.parse('https://www.google.com/generate_204'))
              .timeout(const Duration(seconds: 4));
          final response =
              await request.close().timeout(const Duration(seconds: 4));
          online = response.statusCode == 204 ||
              (response.statusCode >= 200 && response.statusCode < 400);
          await response.drain<void>();
        } finally {
          client.close(force: true);
        }
      }
    } catch (_) {
      online = false;
    } finally {
      _checking = false;
    }
    if (!mounted) return;
    setState(() {
      _hasChecked = true;
      _isOffline = !online;
      if (online) _retrying = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_hasChecked || !_isOffline) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: OfflineView(
            retrying: _retrying,
            onRetry: () {
              setState(() => _retrying = true);
              _checkInternet();
            },
          ),
        ),
      ],
    );
  }
}

class OfflineView extends StatelessWidget {
  const OfflineView({super.key, required this.retrying, required this.onRetry});
  final bool retrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF08143A), Color(0xFF050D2A)]
                : const [Color(0xFFF8FAFF), Color(0xFFEFF4FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue.withValues(alpha: .12),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            color: AppColors.blue,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: constraints.maxHeight < 600 ? 150 : 220,
                          child: Lottie.asset(
                            'assets/animations/network_error.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            errorBuilder: (context, error, stack) => const Icon(
                              Icons.cloud_off_rounded,
                              size: 120,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No internet connection',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Check your Wi-Fi or mobile data. The app will continue automatically when your connection is restored.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: retrying ? null : onRetry,
                            icon: retrying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                            label: Text(
                              retrying ? 'Checking connection...' : 'Try again',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.ink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We will reconnect automatically when a network is available.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
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
