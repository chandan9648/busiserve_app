import 'package:flutter/material.dart';

import '../state/view_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_tokens.dart';
import 'app_button.dart';
import 'hex_shape.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'Loading'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label,
        liveRegion: true,
        child: const SizedBox.square(
          dimension: 32,
          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.blue),
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      badge: HexBadge(icon: icon, size: 64, gradient: AppColors.circuit),
      title: title,
      message: message,
      action: actionLabel != null && onAction != null
          ? AppButton(label: actionLabel!, onPressed: onAction, expand: false)
          : null,
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      badge: HexBadge(
        icon: Icons.wifi_tethering_error_rounded,
        size: 64,
        color: context.brand.danger,
      ),
      title: 'Could not load this',
      message: message,
      action: onRetry == null
          ? null
          : AppButton.secondary(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              expand: false,
            ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.badge,
    required this.title,
    required this.message,
    this.action,
  });

  final Widget badge;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              badge,
              const SizedBox(height: AppSpacing.xl),
              Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: context.text.bodyMedium?.copyWith(color: context.brand.muted),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the right widget for each [ViewState]. Retry is only offered when
/// the failure is marked retryable and [onRetry] is provided.
class StateView<T> extends StatelessWidget {
  const StateView({
    super.key,
    required this.state,
    required this.builder,
    this.onRetry,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Check back later.',
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.loading,
  });

  final ViewState<T> state;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      InitialState<T>() || LoadingState<T>() => loading ?? const LoadingView(),
      SuccessState<T>(:final data) => builder(data),
      EmptyState<T>() => EmptyView(
          title: emptyTitle,
          message: emptyMessage,
          icon: emptyIcon,
          actionLabel: emptyActionLabel,
          onAction: onEmptyAction,
        ),
      ErrorState<T>(:final failure) => ErrorView(
          message: failure.message,
          onRetry: failure.retryable ? onRetry : null,
        ),
    };
  }
}
