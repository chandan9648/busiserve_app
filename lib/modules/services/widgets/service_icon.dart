import 'package:flutter/material.dart';

/// Maps a service's `iconKey` to a Material icon.
IconData serviceIcon(String key) => switch (key) {
      'web' => Icons.language_rounded,
      'app' => Icons.phone_iphone_rounded,
      'cms' => Icons.article_outlined,
      'crm' => Icons.groups_2_outlined,
      'wordpress' => Icons.edit_note_rounded,
      'shop' => Icons.storefront_outlined,
      'erp' => Icons.inventory_2_outlined,
      'design' => Icons.palette_outlined,
      'game' => Icons.sports_esports_outlined,
      'api' => Icons.hub_outlined,
      'ai' => Icons.smart_toy_outlined,
      'automation' => Icons.account_tree_outlined,
      _ => Icons.widgets_outlined,
    };
