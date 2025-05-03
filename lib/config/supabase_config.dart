import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Replace these with your actual Supabase credentials
  static const String _supabaseUrl = 'https://onjvpnmypvxxatotpizs.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uanZwbm15cHZ4eGF0b3RwaXpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyNjU0NzIsImV4cCI6MjA2MTg0MTQ3Mn0.T-RBxI4e1j7KXRY30yiEfb0Sb9M9OsMea2rVDgn4JCw';

  static Future<void> initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        debug: kDebugMode,
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
    }
  }

  // Getter for Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}