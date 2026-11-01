import 'package:flutter/material.dart';

class ThemeManager {
  // 👈 الـ ValueNotifier ده عبارة عن صندوق بنحط فيه الـ ThemeMode الحالي (Light) ويراقب أي تغيير
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  // 👈 دالة ذكية بتقلب الثيم لو لايت تخليه دارك والعكس
  static void toggleTheme() {
    if (themeModeNotifier.value == ThemeMode.light) {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.light;
    }
  }
}
