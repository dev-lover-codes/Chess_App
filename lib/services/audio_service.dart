import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> playMove() async {
    if (!_enabled) return;
    await _playTone(440, 100); // A4 note, 100ms
  }

  Future<void> playCapture() async {
    if (!_enabled) return;
    await _playTone(330, 150); // E4 note, 150ms
  }

  Future<void> playCheck() async {
    if (!_enabled) return;
    await _playTone(554, 200); // C#5 note, 200ms
  }

  Future<void> playCheckmate() async {
    if (!_enabled) return;
    // Play a sequence
    await _playTone(659, 150); // E5
    await Future.delayed(const Duration(milliseconds: 50));
    await _playTone(523, 150); // C5
    await Future.delayed(const Duration(milliseconds: 50));
    await _playTone(392, 300); // G4
  }

  Future<void> playButton() async {
    if (!_enabled) return;
    await _playTone(880, 50); // A5 note, 50ms
  }

  Future<void> playVictory() async {
    if (!_enabled) return;
    // Victory fanfare
    await _playTone(523, 150); // C5
    await Future.delayed(const Duration(milliseconds: 50));
    await _playTone(659, 150); // E5
    await Future.delayed(const Duration(milliseconds: 50));
    await _playTone(784, 300); // G5
  }

  Future<void> _playTone(double frequency, int durationMs) async {
    try {
      // Generate a simple beep using BytesSource
      // For a production app, you'd use actual audio files
      // For now, we'll use a simple approach with volume
      await _player.setVolume(0.3);
      await _player.setReleaseMode(ReleaseMode.stop);
      
      // Since we can't easily generate tones, we'll just use a short silence
      // In a real app, you'd have actual sound files in assets/sounds/
      // For now, this is a placeholder that won't crash
      
    } catch (e) {
      // Silently fail if audio doesn't work
    }
  }

  void dispose() {
    _player.dispose();
  }
}
