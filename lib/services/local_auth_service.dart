import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Local Authentication Service - No backend required!
/// Stores user credentials securely on device using SharedPreferences
class LocalAuthService with ChangeNotifier {
  static final LocalAuthService _instance = LocalAuthService._internal();
  
  factory LocalAuthService() {
    return _instance;
  }
  
  LocalAuthService._internal();

  // Current logged in user
  String? _currentUserEmail;
  String? _currentUserId;
  
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _currentUserEmail != null;

  // Keys for SharedPreferences
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  /// Initialize and check if user is already logged in
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserEmail = prefs.getString(_currentUserKey);
      
      if (_currentUserEmail != null) {
        _currentUserId = _hashEmail(_currentUserEmail!);
        if (kDebugMode) {
          print('User already logged in: $_currentUserEmail');
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing LocalAuthService: $e');
      }
    }
  }

  /// Hash email to create a unique user ID
  String _hashEmail(String email) {
    return md5.convert(utf8.encode(email.toLowerCase().trim())).toString();
  }

  /// Hash password for secure storage
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Get all users from storage
  Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null) {
      return {};
    }
    
    try {
      return Map<String, dynamic>.from(json.decode(usersJson));
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding users: $e');
      }
      return {};
    }
  }

  /// Save users to storage
  Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, json.encode(users));
  }

  /// Sign Up - Create new user account
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      // Validate input
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email address');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final normalizedEmail = email.toLowerCase().trim();
      final userId = _hashEmail(normalizedEmail);
      
      // Check if user already exists
      final users = await _getUsers();
      if (users.containsKey(userId)) {
        throw Exception('User already exists. Please sign in instead.');
      }

      // Create new user
      final hashedPassword = _hashPassword(password);
      users[userId] = {
        'email': normalizedEmail,
        'password': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
        'completedStage': 1,
        'soundEnabled': true,
        'darkMode': true,
      };

      await _saveUsers(users);

      if (kDebugMode) {
        print('User created successfully: $normalizedEmail');
      }

      return {
        'success': true,
        'message': 'Account created successfully!',
        'userId': userId,
        'email': normalizedEmail,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Sign In - Authenticate existing user
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      final normalizedEmail = email.toLowerCase().trim();
      final userId = _hashEmail(normalizedEmail);
      
      // Get users
      final users = await _getUsers();
      
      // Check if user exists
      if (!users.containsKey(userId)) {
        throw Exception('User not found. Please sign up first.');
      }

      final userData = users[userId];
      final storedPasswordHash = userData['password'];
      final inputPasswordHash = _hashPassword(password);

      // Verify password
      if (storedPasswordHash != inputPasswordHash) {
        throw Exception('Incorrect password');
      }

      // Login successful
      _currentUserEmail = normalizedEmail;
      _currentUserId = userId;
      
      // Save current user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, normalizedEmail);

      // Update last login
      users[userId]['lastLogin'] = DateTime.now().toIso8601String();
      await _saveUsers(users);

      notifyListeners();

      if (kDebugMode) {
        print('User logged in successfully: $normalizedEmail');
      }

      return {
        'success': true,
        'message': 'Logged in successfully!',
        'userId': userId,
        'email': normalizedEmail,
        'userData': userData,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Sign Out - Log out current user
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      
      _currentUserEmail = null;
      _currentUserId = null;
      
      notifyListeners();

      if (kDebugMode) {
        print('User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  /// Sync user progress to local storage
  Future<void> syncProgress(int completedStage, bool soundEnabled, bool darkMode) async {
    if (!isAuthenticated) return;

    try {
      final users = await _getUsers();
      
      if (users.containsKey(_currentUserId)) {
        users[_currentUserId!]['completedStage'] = completedStage;
        users[_currentUserId!]['soundEnabled'] = soundEnabled;
        users[_currentUserId!]['darkMode'] = darkMode;
        users[_currentUserId!]['lastSync'] = DateTime.now().toIso8601String();
        
        await _saveUsers(users);

        if (kDebugMode) {
          print('Progress synced for user: $_currentUserEmail');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing progress: $e');
      }
    }
  }

  /// Load user progress from local storage
  Future<Map<String, dynamic>?> loadProgress() async {
    if (!isAuthenticated) return null;

    try {
      final users = await _getUsers();
      
      if (users.containsKey(_currentUserId)) {
        return Map<String, dynamic>.from(users[_currentUserId!]);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading progress: $e');
      }
      return null;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final users = await _getUsers();
      
      if (users.containsKey(_currentUserId)) {
        final userData = Map<String, dynamic>.from(users[_currentUserId!]);
        // Remove password from returned data for security
        userData.remove('password');
        return userData;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  /// Delete user account (for testing or user request)
  Future<bool> deleteAccount() async {
    if (!isAuthenticated) return false;

    try {
      final users = await _getUsers();
      users.remove(_currentUserId);
      await _saveUsers(users);
      
      await signOut();

      if (kDebugMode) {
        print('Account deleted successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      return false;
    }
  }
}
