import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../errors/error_handler.dart';
import '../services/auth_session.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_tokens.dart';
import 'app_button.dart';

/// Asks a signed-in, unverified user to confirm their email, with buttons to
/// resend the link and to re-check once they have clicked it. Hides itself
/// when there is nothing to do.
class EmailVerificationNotice extends StatefulWidget {
  const EmailVerificationNotice({super.key, this.padding = EdgeInsets.zero});
  final EdgeInsetsGeometry padding;

  @override
  State<EmailVerificationNotice> createState() => _EmailVerificationNoticeState();
}

class _EmailVerificationNoticeState extends State<EmailVerificationNotice> {
  static const _resendCooldown = Duration(seconds: 60);

  final AuthSession _session = Get.find<AuthSession>();
  late bool _verified = !_session.isLoggedIn || _session.isEmailVerified;
  bool _checking = false;
  bool _sending = false;
  int _resendIn = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      final ok = await _session.refreshEmailVerified();
      if (!mounted) return;
      if (ok) {
        setState(() => _verified = true);
        Get.snackbar('Email verified', 'Thanks! You can send enquiries and support requests now.');
      } else {
        Get.snackbar('Not verified yet', 'Open the link in the email we sent, then try again.');
      }
    } catch (e) {
      Get.snackbar('Could not check', ErrorHandler.map(e).message);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await _session.sendEmailVerification();
      Get.snackbar('Link sent', 'Check ${_session.email ?? 'your inbox'}, including the spam folder.');
      _startCooldown();
    } catch (e) {
      Get.snackbar('Could not send', ErrorHandler.map(e).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _resendIn = _resendCooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_verified) return const SizedBox.shrink();
    final color = context.colors.tertiary;
    return Padding(
      padding: widget.padding,
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.mark_email_unread_outlined, color: color, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Verify your email to send enquiries and support requests. '
                      'We sent a link to ${_session.email ?? 'your inbox'}.',
                      style: context.text.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppButton(
                    label: "I've verified",
                    icon: Icons.refresh_rounded,
                    expand: false,
                    isLoading: _checking,
                    onPressed: _check,
                  ),
                  AppButton.secondary(
                    label: _resendIn > 0 ? 'Resend in ${_resendIn}s' : 'Resend link',
                    expand: false,
                    isLoading: _sending,
                    onPressed: _resendIn > 0 ? null : _resend,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
