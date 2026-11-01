import 'package:flutter/material.dart';

class AppTheme {
  // ─── 🎨 ألوان البراند الموحدة المحدثة لدرجات هادئة وراقية (Muted Spruce & Steel Blue) ───

  // 🌙 ألوان الـ Dark Mode (مع الحفاظ على الأسماء القديمة تماماً لحماية الشاشات)
  static const Color bgDark = Color(
    0xFF0F1212,
  ); // فحمي دافئ عميق مائل للميرمية مريح جداً للعين
  static const Color cardDark = Color(
    0xFF191E1E,
  ); // رمادي فحمي زمردي مطفي ناعم جداً للكروت
  static const Color neonGreen = Color(
    0xFF6CBD9A,
  ); // أخضر ميرمية نعناعي راقي للنسب والأرقام النشطة (الخط الأول)

  // 💎 تم استبدال الأخضر الداكن بـ أزرق فولاذي ثلجي مطفأ يعطي تبايناً مذهلاً ومريحاً مع الأخضر الميرمية
  static const Color mintGlow = Color(
    0xFF8BB1D6,
  ); // Steel Ice Blue فخم للشارت (الخط الثاني والتأثيرات)

  // ☀️ ألوان الـ Light Mode (تم ضبط التباين لثبات الأرضية بصرياً)
  static const Color bgLight = Color(
    0xFFF3F6F5,
  ); // خلفية فاتحة هادئة جداً مائلة للميرمية لتثبيت الكروت
  static const Color cardLight = Colors.white; // كروت بيضاء نظيفة تماماً
  static const Color deepGreen = Color.fromARGB(
    255,
    63,
    114,
    86,
  ); // أخضر زمردي ملكي مطفي للنصوص والأزرار الأساسية

  static const Color alertRed = Color.fromARGB(
    255,
    184,
    84,
    80,
  ); // الأحمر الدافئ الهادئ للتنبيهات

  // ☀️ ثيم الـ Light Mode الموحد والأنيق (Borderless Style)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: deepGreen,
      scaffoldBackgroundColor: bgLight,
      cardColor: cardLight,
      fontFamily: 'Urbanist',

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color.fromARGB(255, 36, 66, 49),
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(color: deepGreen, fontWeight: FontWeight.w800),
        bodyLarge: TextStyle(
          color: Color(0xFF2D3732), // أسود مخضر دافئ للقراءة والوضوح
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF6B7A72), // رمادي مائل للميرمية للنصوص الثانوية
          fontWeight: FontWeight.w500,
        ),
      ),

      colorScheme: const ColorScheme.light(
        primary: deepGreen,
        secondary: neonGreen,
        surface: cardLight,
        outline: Colors
            .transparent, // كروت نظيفة بدون حدود تعتمد كلياً على الظل الناعم
      ),
    );
  }

  // 🌙 ثيم الـ Dark Mode الأسطوري المطور (Premium Warm Charcoal Style)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: neonGreen,
      scaffoldBackgroundColor: bgDark,
      cardColor: cardDark,
      fontFamily: 'Urbanist',

      textTheme: TextTheme(
        displayLarge: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.w500,
        ),
      ),

      colorScheme: ColorScheme.dark(
        primary: neonGreen, // اللون الأساسي المحدث (أخضر ميرمية نعناعي)
        secondary:
            mintGlow, // اللون الثانوي الفخم والجديد (الأزرق الفولاذي المطفأ)
        surface: cardDark,
        outline: Colors.white.withValues(
          alpha: 0.015,
        ), // لمعان زجاجي خفيف جداً لتحديد الكروت بالظلام
      ),
    );
  }
}
