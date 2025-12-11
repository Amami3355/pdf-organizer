import 'package:flutter/material.dart';
import 'dart:ui';

/// 🔮 Reusable Glassmorphism Toolbar Widget
///
/// Extracted from EditorScreen for reuse in other screens.
/// Provides a frosted glass effect with blur and subtle border.

class GlassToolbar extends StatelessWidget {
  final List<GlassToolbarItem> items;
  final EdgeInsetsGeometry? margin;
  
  const GlassToolbar({
    super.key,
    required this.items,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(
        bottom: 32 + MediaQuery.paddingOf(context).bottom,
        left: 24,
        right: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2633).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.map((item) => _GlassToolbarItemWidget(item: item)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for toolbar items
class GlassToolbarItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const GlassToolbarItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

class _GlassToolbarItemWidget extends StatelessWidget {
  final GlassToolbarItem item;

  const _GlassToolbarItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: Theme.of(context).hintColor),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
