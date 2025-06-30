import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tasknest/firebase_options.dart';
import 'package:tasknest/routes/app_routes.dart';
import 'package:tasknest/screens/auth/gate.dart';
import 'package:tasknest/utils/app_text_theme.dart';
import 'package:tasknest/utils/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Nest',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: AppColors.primary,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
        // scaffoldBackgroundColor: AppColors.background,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          titleTextStyle: CustomTextStyle.titleLarge(context).copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: const BorderSide(
            color: Colors.grey,
            width: 1.5,
          ),
          checkColor: WidgetStateProperty.all(AppColors.grayLight),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.all(AppColors.primary),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionHandleColor: AppColors.primary,
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(12),
          prefixIconColor: AppColors.primary,
          hintStyle: CustomTextStyle.labelMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.gray,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grayLight),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.tertiary),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.tertiary),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            iconSize: WidgetStateProperty.all(24),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            backgroundColor: WidgetStateProperty.all(AppColors.primary),
            foregroundColor: WidgetStateProperty.all(AppColors.white),
            textStyle: WidgetStateProperty.all(
              GoogleFonts.outfit(
                textStyle: CustomTextStyle.labelLarge(context).copyWith(
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.outfit(
              textStyle: CustomTextStyle.labelLarge(context).copyWith(
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              GoogleFonts.outfit(
                textStyle: CustomTextStyle.labelLarge(context).copyWith(
                  letterSpacing: 0.5,
                  color: AppColors.tertiary,
                ),
              ),
            ),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.grayLight,
        ),
      ),
      home: const Gate(),
      getPages: AppRoutes.routes,
    );
  }
}