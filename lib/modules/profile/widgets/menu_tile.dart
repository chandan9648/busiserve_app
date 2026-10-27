import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';

class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Semantics(header: true, child: Text(title, style: context.text.titleSmall?.copyWith(color: context.brand.muted))),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(indent: 56),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.brand.danger : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: context.text.titleSmall?.copyWith(color: color)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: context.text.bodySmall),
      trailing: trailing ?? (onTap == null ? null : Icon(Icons.chevron_right_rounded, color: context.brand.muted)),
      onTap: onTap,
      shape: const RoundedRectangleBorder(),
    );
  }
}
