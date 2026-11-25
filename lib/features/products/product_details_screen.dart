import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🔧 إضافة
import 'package:inventory_pro/core/utils/compact_number.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/data/models/transaction_model.dart'; // 🔧
import 'package:inventory_pro/logic/cubits/product_cubit.dart';
import 'package:inventory_pro/logic/cubits/transaction_cubit.dart'; // 🔧
import 'package:inventory_pro/features/products/add_product.dart';
import 'package:inventory_pro/widgets/product_image.dart';
import 'package:inventory_pro/widgets/soft_ui.dart';
import 'package:inventory_pro/widgets/restock_dialog.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late int currentQuantity;

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.product.quantity;
  }

  void _recordTransaction({
    required String name,
    required double amount,
    required bool isIncome,
    required int qtyChange,
  }) {
    context.read<TransactionCubit>().addTransaction(
      TransactionModel(
        productId: widget.product.id, // 🔧 الجديد
        entityName: name,
        date: _formattedNow(),
        amount: amount,
        isIncome: isIncome,
        status: TransactionStatus.paid,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        quantityChange: qtyChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLowStock = currentQuantity < 10;

    return Scaffold(
      body: Container(
        // 1. خلفية متدرجة ناعمة متناسقة مع ثيم التطبيق
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(
                alpha: 0.099,
              ), // درجة خفيفة جداً من لون الثيم الأساسي فوق
              colorScheme.surface, // باقي الشاشة من لون الخلفية للثيم
            ],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 2. Top Bar (الأزرار العائمة العلوية)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SoftCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    SoftCircleButton(
                      icon: Icons.edit_outlined,
                      onTap: () => Navigator.push(
                        // 🔧
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddProductScreen(product: widget.product),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 3. Left Headline Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  "Product Details",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // 4. Hero Product Image + Triangle Side Steppers
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // صورة المنتج العريضة
                    Hero(
                      tag: 'productGrid-${widget.product.id}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: ProductImage(
                          path: widget.product.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // سهم النقصان الجانبي المثلث (-)
                    Positioned(
                      left: 0,
                      child: SideTriangleStepper(
                        icon: Icons.remove,
                        isLeft: true,
                        onTap: () {
                          if (currentQuantity > 0) {
                            final updated = widget.product.copyWith(
                              quantity: currentQuantity - 1,
                            );
                            context.read<ProductCubit>().updateProduct(updated);
                            _recordTransaction(
                              name: widget.product.name,
                              amount: widget.product.price,
                              isIncome: true,
                              qtyChange: -1,
                            );
                            setState(() => currentQuantity--);
                          }
                        },
                      ),
                    ),

                    // سهم الزيادة الجانبي المثلث (+)
                    Positioned(
                      right: 0,
                      child: SideTriangleStepper(
                        icon: Icons.add,
                        isLeft: false,
                        onTap: () {
                          final updated = widget.product.copyWith(
                            quantity: currentQuantity + 1,
                          );
                          context.read<ProductCubit>().updateProduct(updated);
                          _recordTransaction(
                            name: "${widget.product.name} (Restock)",
                            amount: widget.product.costPrice,
                            isIncome: false,
                            qtyChange: 1,
                          );
                          setState(() => currentQuantity++);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Product Title & Price
              Text(
                widget.product.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "\$${widget.product.price.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 25),

              // 6. Horizontal Soft Pills Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SoftPill(
                      label:
                          "Val: \$${(compactNumber(widget.product.price * currentQuantity))}",
                    ),
                    const SizedBox(width: 12),
                    SoftPill(label: "SKU:  ${widget.product.sku}"),
                    const SizedBox(width: 12),
                    // الكبسولة البارزة المرتبطة بلون الـ Primary الخاص بالـ Theme
                    HighlightPill(
                      label: "$currentQuantity Units",
                      bgColor: isLowStock
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    SoftPill(label: isLowStock ? "Low Stock" : "In Stock"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 7. Bottom Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // المربع الملون بحسب لون الأيقونات بالثيم
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.add_business_rounded,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: _restock,
                          child: Center(
                            child: Text(
                              "Quick Restock Inventory",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restock() async {
    final added = await showRestockDialog(context, widget.product);
    if (added == null || added <= 0 || !mounted) return;

    context.read<ProductCubit>().updateProduct(
      widget.product.copyWith(quantity: currentQuantity + added),
    );
    _recordTransaction(
      name: "${widget.product.name} (Restock)",
      amount: widget.product.costPrice * added,
      isIncome: false,
      qtyChange: added,
    );
    setState(() => currentQuantity += added);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Stock updated successfully!")),
    );
  }
}

String _formattedNow() {
  final now = DateTime.now();
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final hour = now.hour.toString().padLeft(2, '0');
  final minute = now.minute.toString().padLeft(2, '0');
  return "${now.day} ${months[now.month - 1]} • $hour:$minute";
}
