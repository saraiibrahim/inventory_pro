import 'package:flutter/material.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:inventory_pro/features/products/product_details_screen.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/widgets/product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color purple = theme.colorScheme.primary;
    final Color green = theme.colorScheme.secondary;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF1A1D24).withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ منطقة الصورة مع تأثير إبراز الشنط الغامقة (Spotlight)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1F26)
                      : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(18),
                  gradient: isDark
                      ? RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          radius: 0.8,
                        )
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Hero(
                        tag: 'productGrid-${product.id}',
                        child: ProductImage(
                          path: product.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // مؤشر الكمية الهادئ
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: product.quantity < 10
                              ? AppTheme.alertRed
                              : green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (product.quantity < 10
                                          ? AppTheme.alertRed
                                          : green)
                                      .withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 📝 الاسم والسعر والكمية المتبقية بتناسق تام
            Text(
              product.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : purple,
                  ),
                ),
                Text(
                  "${product.quantity} left",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: product.quantity < 10
                        ? AppTheme.alertRed
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
