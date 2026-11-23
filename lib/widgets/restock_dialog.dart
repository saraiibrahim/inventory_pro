import 'package:flutter/material.dart';
import 'package:inventory_pro/data/models/product_model.dart';

/// بيرجّع الكمية اللي المستخدم كتبها، أو null لو ضغط Cancel
Future<int?> showRestockDialog(BuildContext context, ProductModel product) {
  final controller = TextEditingController();
  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        "Restock ${product.name}",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "Enter added quantity...",
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text) ?? 0),
          child: const Text("Update"),
        ),
      ],
    ),
  );
}