import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_pro/data/models/product_model.dart';
import 'package:inventory_pro/logic/cubits/product_cubit.dart';
import 'package:inventory_pro/core/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as pth;

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.product != null; // 🔧

  @override
  void initState() {
    // 🔧
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _costPriceController.text = p.costPrice.toString();
      _quantityController.text = p.quantity.toString();
      _skuController.text = p.sku;
      _selectedCategory = p.category;
      _imagePath = p.image.startsWith('assets/') ? null : p.image;
    }
  }

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _skuController = TextEditingController();

  String? _imagePath;

  String _selectedCategory = 'Bags';
  final List<String> _categories = [
    'Bags',
    'Backpacks',
    'Luggage',
    'Accessories',
    'Wallets',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _quantityController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return; // المستخدم لغى

    // 🔧 ننسخ الصورة لمخزن التطبيق
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${pth.extension(image.path)}';
    final saved = await File(image.path).copy('${dir.path}/$fileName');

    if (!mounted) return; // 🔧 زي ما اتعلمنا بعد أي await
    setState(() => _imagePath = saved.path);
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final double costPrice =
          double.tryParse(_costPriceController.text) ?? (price * 0.7);

      final newProduct = ProductModel(
        id: widget.product?.id ?? 0,
        name: _nameController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
            : _skuController.text.trim(),
        price: price,
        costPrice: costPrice,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        category: _selectedCategory,
        image: _imagePath ?? widget.product?.image ?? 'assets/images/1.png',
      );

      final cubit = context.read<ProductCubit>();
      _isEdit ? cubit.updateProduct(newProduct) : cubit.addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? "تم تعديل المنتج!" : "تم إضافة المنتج بنجاح!",
          ),
          backgroundColor: Colors.green.withAlpha(200),
        ),
      );

      final nav = Navigator.of(context); // 🔧
      nav.pop();
      if (_isEdit) nav.pop();
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete product?"),
        content: Text(
          "\"${widget.product!.name}\" will be removed permanently.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      context.read<ProductCubit>().deleteProduct(widget.product!.id);
      Navigator.of(context)
        ..pop()
        ..pop(); // نرجع للقايمة
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color cardBg = theme.cardColor;
    final Color borderGlint = theme.colorScheme.outline;
    final Color primaryColor = theme.colorScheme.primary;
    final Color mainTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.white;
    final Color textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: mainTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? "Edit Product" : "Add New Product",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: mainTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderGlint),
                    image: _imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath != null
                      ? null
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                size: 28,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Upload Product Image",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: mainTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "PNG, JPG or WEBP up to 5MB",
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderGlint),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: cardBg,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: textMuted,
                    ),
                    items: _categories.map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: mainTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              sectionLabel("PRICING & STOCK", primaryColor),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildCustomTextField(
                      context,
                      controller: _priceController,
                      label: "Price (\$) ",
                      hint: "299.00",
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Required";
                        final n = double.tryParse(val);
                        if (n == null || n < 0) return "Enter a valid price";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildCustomTextField(
                      context,
                      controller: _costPriceController,
                      label: "Cost (\$) ",
                      hint: "180.00",
                      icon: Icons.money_off_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return null;
                        final n = double.tryParse(val);
                        if (n == null || n < 0) return "Enter a valid cost";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCustomTextField(
                      context,
                      controller: _quantityController,
                      label: "Initial Stock",
                      hint: "25",
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,

                      validator: (val) {
                        if (val == null || val.isEmpty) return "Required";
                        final n = int.tryParse(val);
                        if (n == null) return "Enter a whole number";
                        if (n < 0) return "Can't be negative";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildCustomTextField(
                      context,
                      controller: _skuController,
                      label: "SKU (Optional)",
                      hint: "SKU-9021-X",
                      icon: Icons.qr_code_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _saveProduct,
                  child: Text(
                    _isEdit ? "Save Changes" : "Save & Publish Product",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_isEdit) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _confirmDelete,
                    child: Text(
                      "Delete Product",
                      style: TextStyle(
                        color: AppTheme.alertRed,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCustomTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        filled: true,
        fillColor: theme.cardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
