import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/brand_tokens.dart';

enum AppButtonVariant { primary, secondary, text }

/// Primary actions use the orange "growth arrow" gradient from the logo.
/// While [isLoading] is true the button is disabled and shows progress, which
/// also prevents double submission.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: variant == AppButtonVariant.primary
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.sm),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    switch (variant) {
      case AppButtonVariant.secondary:
        return OutlinedButton(onPressed: enabled ? onPressed : null, child: child);
      case AppButtonVariant.text:
        return TextButton(onPressed: enabled ? onPressed : null, child: child);
      case AppButtonVariant.primary:
        final radius = BorderRadius.circular(AppRadius.field);
        return Semantics(
          button: true,
          enabled: enabled,
          label: isLoading ? '$label, in progress' : label,
          excludeSemantics: true,
          child: Opacity(
            opacity: enabled || isLoading ? 1 : 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.brand.actionGradient,
                borderRadius: radius,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF24E12).withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: enabled ? onPressed : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget + 4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: DefaultTextStyle.merge(
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                        child: IconTheme.merge(
                          data: const IconThemeData(color: Colors.white),
                          child: child,
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
}
