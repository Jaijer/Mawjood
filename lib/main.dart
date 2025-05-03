import 'package:flutter/material.dart';
import 'package:mawjood/screens/landing_page/landing_page.dart';
import 'config/theme.dart';
import 'config/supabase_config.dart';  // Import the new Supabase config

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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light, // System default theme
      home: const LandingPage(),
    );
  }
}