import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../../enquiry/models/enquiry_model.dart';
import '../controllers/my_enquiries_controller.dart';
import '../models/quotation_model.dart';
import '../widgets/quotation_tiles.dart';

class MyEnquiriesView extends GetView<MyEnquiriesController> {
  const MyEnquiriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enquiries and quotations'),
          bottom: const TabBar(tabs: [Tab(text: 'Enquiries'), Tab(text: 'Quotations')]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.newEnquiry,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New enquiry'),
        ),
        body: ResponsiveBody(
          child: TabBarView(
            children: [
              Obx(
                () => StateView<List<EnquiryModel>>(
                  state: controller.enquiries.value,
                  onRetry: controller.loadEnquiries,
                  emptyTitle: 'No enquiries yet',
                  emptyMessage: 'Enquiries you send while signed in appear here with their status.',
                  emptyIcon: Icons.mark_chat_unread_outlined,
                  builder: (items) => _List(children: [for (final e in items) EnquiryTile(enquiry: e)]),
                ),
              ),
              Obx(
                () => StateView<List<QuotationModel>>(
                  state: controller.quotations.value,
                  onRetry: controller.loadQuotations,
                  emptyTitle: 'No quotations yet',
                  emptyMessage: 'When we prepare a quotation for you, it will appear here.',
                  emptyIcon: Icons.request_quote_outlined,
                  builder: (items) => _List(
                    children: [
                      for (final q in items) QuotationTile(quotation: q, onTap: () => controller.openQuotation(q)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.lg, AppSpacing.page, 96),
      itemCount: children.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) => children[i],
    );
  }
}
