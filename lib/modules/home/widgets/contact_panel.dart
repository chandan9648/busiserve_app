import 'package:flutter/material.dart';

import '../../../core/constants/company_info.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/app_button.dart';

/// "What would you like to build?" block with the verified contact details.
class ContactPanel extends StatelessWidget {
  const ContactPanel({
    super.key,
    required this.onStart,
    required this.onCall,
    required this.onEmail,
    required this.onMap,
  });

  final VoidCallback onStart;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.panel - 6),
        border: Border.all(color: context.brand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What would you like to build?', style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tell us about your goals, your challenges and where you want to go next.',
            style: context.text.bodyMedium?.copyWith(color: context.brand.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ContactRow(icon: Icons.call_outlined, label: CompanyInfo.phoneDisplay, hint: 'Call us', onTap: onCall),
          _ContactRow(icon: Icons.mail_outline_rounded, label: CompanyInfo.email, hint: 'Email us', onTap: onEmail),
          _ContactRow(icon: Icons.place_outlined, label: CompanyInfo.address, hint: 'Open in maps', onTap: onMap),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Start a conversation', icon: Icons.chat_bubble_outline_rounded, onPressed: onStart),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label, required this.hint, required this.onTap});
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$hint: $label',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 20, color: context.colors.tertiary),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
