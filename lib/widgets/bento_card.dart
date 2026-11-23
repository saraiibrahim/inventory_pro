import 'package:flutter/material.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final ThemeData theme;
  final bool isDark;
  final double height;
  final EdgeInsetsGeometry padding;

  const BentoCard({
    required this.child,
    required this.theme,
    required this.isDark,
    required this.height,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 سحب لون الكارت مباشرة من ملف الثيم لتوحيد جميع الكروت بالأبلكيشن

    // 🔒 تأثير الظل المزدوج الفاخر لتثبيت الكارت في الـ Light Mode
    final List<BoxShadow> bentoShadows = isDark
        ? []
        : [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.025),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.008),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ];

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
        boxShadow: bentoShadows,
      ),
      child: child,
    );
  }
}
