import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.background,
    error: AppColors.error,
  ),
  fontFamily: 'Vazirmatn',
  scaffoldBackgroundColor: AppColors.background,
  textTheme: appTextTheme,
  useMaterial3: true,
);

