import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/common.dart';

/// Shared layout for sign-in, register and password reset.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.children});
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ResponsiveBody(
          maxWidth: 480,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page + 4, 0, AppSpacing.page + 4, AppSpacing.xxl),
            children: [
              const Align(alignment: Alignment.centerLeft, child: BrandLogo(height: 64)),
              const SizedBox(height: AppSpacing.xl),
              Semantics(header: true, child: Text(title, style: context.text.headlineMedium)),
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle, style: context.text.bodyLarge?.copyWith(color: context.brand.muted)),
              const SizedBox(height: AppSpacing.xl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class FormError extends StatelessWidget {
  const FormError({super.key, required this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InlineNotice(message: message!, icon: Icons.error_outline_rounded, isError: true),
    );
  }
}
