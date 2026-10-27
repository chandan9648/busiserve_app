import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/quotation_detail_controller.dart';
import '../models/quotation_model.dart';

class QuotationDetailView extends GetView<QuotationDetailController> {
  const QuotationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotation')),
      body: Obx(
        () => StateView<QuotationModel>(
          state: controller.state.value,
          onRetry: controller.load,
          builder: (q) {
            String money(double v) => Formatters.currency(v, currency: q.currency);
            return ResponsiveBody(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxl),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: AppColors.hero,
                      borderRadius: BorderRadius.circular(AppRadius.panel - 6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.title, style: context.text.titleLarge?.copyWith(color: Colors.white)),
                        const SizedBox(height: AppSpacing.lg),
                        Text(money(q.total), style: context.text.displaySmall?.copyWith(color: Colors.white)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          q.validUntil == null ? q.status.label : '${q.status.label}, valid until ${Formatters.date(q.validUntil)}',
                          style: context.text.bodyMedium?.copyWith(color: AppColors.amber),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Breakdown', style: context.text.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      children: [
                        for (final item in q.items) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.description, style: context.text.bodyMedium),
                                    if (item.quantity != 1)
                                      Text(
                                        '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} × ${money(item.unitPrice)}',
                                        style: context.text.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(money(item.amount), style: context.text.titleSmall),
                            ],
                          ),
                          const Divider(height: AppSpacing.xl),
                        ],
                        _TotalRow(label: 'Subtotal', value: money(q.subtotal)),
                        if (q.tax > 0) _TotalRow(label: 'Tax', value: money(q.tax)),
                        _TotalRow(label: 'Total', value: money(q.total), strong: true),
                      ],
                    ),
                  ),
                  if (q.notes != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text('Notes', style: context.text.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(q.notes!, style: context.text.bodyMedium?.copyWith(color: context.brand.muted)),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: 'Ask about this quotation',
                    icon: Icons.forum_outlined,
                    onPressed: controller.discuss,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'To accept or change a quotation, send us a message. Work starts after we confirm scope with you.',
                    style: context.text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong ? context.text.titleMedium : context.text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(children: [Expanded(child: Text(label, style: style)), Text(value, style: style)]),
    );
  }
}
