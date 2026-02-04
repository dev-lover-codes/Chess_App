import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/game_config.dart';
import '../services/local_auth_service.dart';

class StageProvider extends ChangeNotifier {
  Set<int> _completedStages = {};
  int _currentStage = 1;
  bool _soundEnabled = true;
  bool _darkMode = false;

  Set<int> get completedStages => _completedStages;
  int get currentStage => _currentStage;
  bool get soundEnabled => _soundEnabled;
  bool get darkMode => _darkMode;

  int get highestUnlockedStage {
    if (_completedStages.isEmpty) return 1;
    return _completedStages.reduce((a, b) => a > b ? a : b) + 1;
  }

  bool isStageUnlocked(int stage) {
    if (stage == 1) return true;
    return _completedStages.contains(stage - 1);
  }

  bool isStageCompleted(int stage) {
    return _completedStages.contains(stage);
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load completed stages
    final completedList = prefs.getStringList(GameConfig.storageKeyProgress) ?? [];
    _completedStages = completedList.map((s) => int.parse(s)).toSet();
    
    // Load settings
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _darkMode = prefs.getBool('dark_mode') ?? false;
    
    notifyListeners();
  }

  Future<void> completeStage(int stage) async {
    if (!_completedStages.contains(stage)) {
      _completedStages.add(stage);
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = _completedStages.map((s) => s.toString()).toList();
    await prefs.setStringList(GameConfig.storageKeyProgress, completedList);

    // Sync to Local Auth Storage (if logged in)
    final highestStage = _completedStages.isEmpty 
        ? 0 
        : _completedStages.reduce((a, b) => a > b ? a : b);
    
    try {
      final authService = LocalAuthService();
      if (authService.isAuthenticated) {
        await authService.syncProgress(highestStage, _soundEnabled, _darkMode);
      }
    } catch (e) {
      if (kDebugMode) {
        print('User progress sync failed: $e');
      }
    }
  }
  
  // Call this from AuthScreen after successful login
  Future<void> syncFromCloud(int highestCompletedStage) async {
    // If user account has higher progress, update local
    // Assuming linear progression: if stage 5 is done, 1-4 are done.
    bool changed = false;
    for (int i = 1; i <= highestCompletedStage; i++) {
        if (!_completedStages.contains(i)) {
            _completedStages.add(i);
            changed = true;
        }
    }
    
    if (changed) {
        await _saveProgress();
        notifyListeners();
    }
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _darkMode);
    notifyListeners();
  }

  void setCurrentStage(int stage) {
    _currentStage = stage;
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _completedStages.clear();
    _currentStage = 1;
    await _saveProgress();
    notifyListeners();
  }
}
