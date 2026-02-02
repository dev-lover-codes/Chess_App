import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService with ChangeNotifier {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // These are placeholders! You need to replace them with your actual Supabase keys
  // from https://supabase.com
  static const String supabaseUrl = 'https://jsbfbdkqwmxdinjnjhbh.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_GeqNfY3yPdzXwJ7RBykowQ_T8V19b_M';

  User? get currentUser => Supabase.instance.client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      if (kDebugMode) {
        print('Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Supabase: $e');
      }
    }
  }

  // Sign Up
  Future<AuthResponse> signUp(String email, String password) async {
    return await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign In
  Future<AuthResponse> signIn(String email, String password) async {
    return await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }

  // Sync Progress to Cloud
  Future<void> syncProgress(int completedStage, bool soundEnabled, bool darkMode) async {
    if (!isAuthenticated) return;

    try {
      final userId = currentUser!.id;
      
      // Upsert (Insert or Update) profile data
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'completed_stage': completedStage,
        'sound_enabled': soundEnabled,
        'dark_mode': darkMode,
        'last_login': DateTime.now().toIso8601String(),
      });
      
      if (kDebugMode) {
        print('Progress synced to cloud!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing progress: $e');
      }
    }
  }

  // Load Progress from Cloud
  Future<Map<String, dynamic>?> loadProgress() async {
    if (!isAuthenticated) return null;

    try {
      final userId = currentUser!.id;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading progress: $e');
      }
      return null;
    }
  }
}
