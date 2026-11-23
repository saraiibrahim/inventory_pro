import 'package:flutter/material.dart';

List<BoxShadow> cardShadowsOf(ThemeData theme) {
  if (theme.brightness == Brightness.dark) return [];
  return [
    BoxShadow(
      color: theme.colorScheme.primary.withValues(alpha: 0.025),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.008),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}

BoxDecoration cardDecorationOf(ThemeData theme, {double radius = 24}) {
  return BoxDecoration(
    color: theme.cardColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.colorScheme.outline),
    boxShadow: cardShadowsOf(theme),
  );
}
