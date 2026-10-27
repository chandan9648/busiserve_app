import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/hex_shape.dart';
import '../models/case_study_model.dart';

IconData industryIcon(String industry) => switch (industry.toLowerCase()) {
      'finance' => Icons.account_balance_outlined,
      'retail' => Icons.shopping_bag_outlined,
      'technology' => Icons.memory_rounded,
      _ => Icons.work_outline_rounded,
    };

/// Navy panel with the hex lattice; the industry sits in an orange hexagon.
class CaseStudyCard extends StatelessWidget {
  const CaseStudyCard({super.key, required this.study, required this.onTap, this.compact = false});
  final CaseStudyModel study;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card + 4);
    return Semantics(
      button: true,
      label: '${study.title}, ${study.industry} case study',
      excludeSemantics: true,
      child: Material(
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        color: AppColors.ink,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: HexLatticePainter(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        HexBadge(icon: industryIcon(study.industry), size: 36, gradient: AppColors.arrow),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          study.industry,
                          style: context.text.bodySmall?.copyWith(
                            color: AppColors.amber,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(study.title, style: context.text.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      study.summary,
                      maxLines: compact ? 3 : 5,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.78)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
