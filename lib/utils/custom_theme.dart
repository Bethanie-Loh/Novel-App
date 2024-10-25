import 'package:flutter/material.dart';
import 'package:novel_app/utils/app_text_styles.dart'; // Your text styles

class CustomTheme {
  static const TextTheme textTheme = TextTheme(
    displayLarge: AppTextStyles.bold_26, // Large display text
    displayMedium: AppTextStyles.bold_24, // Medium display text
    displaySmall: AppTextStyles.bold_20, // Small display text
    headlineLarge: AppTextStyles.bold_white_20, // Large headline
    headlineMedium: AppTextStyles.bold_18, // Medium headline
    headlineSmall: AppTextStyles.bold_14, // Small headline
    titleLarge: AppTextStyles.bold_26, // Large title
    titleMedium: AppTextStyles.bold_24, // Medium title
    titleSmall: AppTextStyles.bold_20, // Small title
    bodyLarge: AppTextStyles.regular_16, // Large body text
    bodyMedium: AppTextStyles.regular_12, // Medium body text
    bodySmall: AppTextStyles.bold_12, // Small body text
    labelLarge: AppTextStyles.bold_20, // Large label text (e.g., buttons)
    labelMedium: AppTextStyles.bold_18, // Medium label text
    labelSmall: AppTextStyles.bold_14, // Small label text
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    textTheme: textTheme,
    // You can further customize other theme properties like buttons, input fields, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    textTheme: textTheme,
  );
}
