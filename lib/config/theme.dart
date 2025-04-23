import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';

class AppTheme {
  static String fontFamily = "Cairo";
  static ThemeData appTheme = ThemeData(
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        color: AppColors.white,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: Colors.grey[600],
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return  TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.main);
          }
          return const TextStyle(
            fontWeight: FontWeight.normal,
          );
        }),
      ),
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: fontFamily,
      progressIndicatorTheme:
       ProgressIndicatorThemeData(color: AppColors.main),
      inputDecorationTheme:  InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.main),
          ),
          focusColor: AppColors.main),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.main,
        selectionColor: AppColors.main.withOpacity(0.3),
        selectionHandleColor: AppColors.main,
      ));
}
