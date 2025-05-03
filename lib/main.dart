import 'package:flutter/material.dart';
import 'package:mawjood/screens/landing_page/landing_page.dart';
import 'components/theme2.dart'; // Updated import path
import 'config/supabase_config.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initializeSupabase();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KFUPM Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Using our AppTheme class
      darkTheme: AppTheme.darkTheme, // Using our AppTheme class
      themeMode: ThemeMode.light, // System default theme
      home: const LandingPage(),
    );
  }
}