import 'package:flutter/material.dart';

import '../../../core/constants/company_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/hex_shape.dart';

/// Home hero: the navy hexagon field with the orange growth trace from the
/// logo running behind the headline.
class HeroPanel extends StatelessWidget {
  const HeroPanel({super.key, required this.onStart, required this.onExplore});
  final VoidCallback onStart;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page - 6),
      decoration: BoxDecoration(
        gradient: AppColors.hero,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.28), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: HexLatticePainter(
                color: Colors.white.withValues(alpha: 0.06),
                accent: AppColors.amber.withValues(alpha: 0.9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your digital development partner',
                  style: context.text.bodyMedium?.copyWith(color: AppColors.sky, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  header: true,
                  child: Text(
                    CompanyInfo.tagline,
                    style: context.text.displaySmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  CompanyInfo.intro,
                  style: context.text.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Pill('Web & Apps'),
                    _Pill('CMS, CRM & ERP'),
                    _Pill('AI & Automation'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: 'Get a free consultation', onPressed: onStart),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onExplore,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Explore services'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: context.text.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
