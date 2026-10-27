import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/hex_shape.dart';
import '../models/service_model.dart';
import 'service_icon.dart';

/// Row-style card for lists.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});
  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      semanticLabel: '${service.title}. ${service.summary}',
      child: Row(
        children: [
          HexBadge(icon: serviceIcon(service.iconKey), size: 48, gradient: AppColors.circuit),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title, style: context.text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  service.focusAreas.join(', '),
                  style: context.text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.brand.muted),
        ],
      ),
    );
  }
}

/// Compact tile for the home grid.
class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service, required this.onTap});
  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      semanticLabel: service.title,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HexBadge(icon: serviceIcon(service.iconKey), size: 38, gradient: AppColors.circuit),
          Text(
            service.title,
            style: context.text.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
