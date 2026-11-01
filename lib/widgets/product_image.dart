import 'dart:io';

import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  const ProductImage({super.key, required this.path, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit);
    }
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/images/1.png', fit: fit),
    );
  }
}
