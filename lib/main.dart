import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'presentation/screens/main_scaffold_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CamburPintonApp());
}

class CamburPintonApp extends StatelessWidget {
  const CamburPintonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primaryAmber,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryAmber,
          secondary: AppColors.secondaryCopper,
          surface: AppColors.backgroundCard,
        ),
        textTheme: ThemeData.dark().textTheme,
      ),
      home: const MainScaffoldScreen(),
    );
  }
}
