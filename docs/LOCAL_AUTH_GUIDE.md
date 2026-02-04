# Local Authentication Setup

## ✅ No Backend Required!

This Chess Master app now uses **local authentication** - no Supabase, no backend, no internet required! Everything is stored securely on your device.

## How It Works

### User Accounts
- **Sign Up**: Creates a new user account stored locally on your device
- **Sign In**: Authenticates against locally stored credentials
- **Password Security**: Passwords are hashed using SHA-256 (never stored in plain text)
- **User Data**: Each user's progress is stored separately

### What's Stored
- Email address (encrypted)
- Password hash (SHA-256)
- Game progress (completed stages)
- Settings (sound, dark mode)
- Last login time

### Storage Location
All data is stored using `SharedPreferences`:
- **Windows**: `%APPDATA%\chess_master\shared_preferences.json`
- **Android**: `/data/data/com.yourapp.chess_master/shared_prefs/`
- **iOS**: `Library/Preferences/`

## Features

✅ **No Internet Required** - Everything works offline  
✅ **Secure Storage** - Passwords hashed with SHA-256  
✅ **Multiple Users** - Each user has separate progress  
✅ **Guest Mode** - Play without an account  
✅ **Progress Sync** - Logged-in users' progress is saved per account  

## User Flow

### First Time User
1. Launch app → Landing Screen
2. Tap "Sign Up"
3. Enter email + password (min 6 characters)
4. Account created → Switch to Sign In
5. Sign in with same credentials
6. Play and progress is saved!

### Returning User
1. Launch app → Landing Screen
2. Tap "Sign In"
3. Enter credentials
4. Progress loads automatically
5. Continue playing from where you left off

### Guest Mode
1. Launch app → Landing Screen
2. Tap "Play as Guest"
3. Play immediately (no login)
4. Progress saved locally, not tied to account

## Security Features

### Password Hashing
```dart
// Passwords are hashed before storage
String _hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}
```

### User ID Generation
```dart
// Email is hashed to create unique user ID
String _hashEmail(String email) {
  return md5.convert(utf8.encode(email.toLowerCase().trim())).toString();
}
```

### Data Validation
- Email must contain "@"
- Password must be 6+ characters
- Email is normalized (lowercase, trimmed)

## API Reference

### LocalAuthService

#### Initialize
```dart
await LocalAuthService().initialize();
```

#### Sign Up
```dart
final result = await LocalAuthService().signUp(email, password);
// Returns: { 'success': bool, 'message': String, ... }
```

#### Sign In
```dart
final result = await LocalAuthService().signIn(email, password);
// Returns: { 'success': bool, 'message': String, 'userData': Map }
```

#### Sign Out
```dart
await LocalAuthService().signOut();
```

#### Check Authentication Status
```dart
bool isLoggedIn = LocalAuthService().isAuthenticated;
String? email = LocalAuthService().currentUserEmail;
```

#### Sync Progress
```dart
await LocalAuthService().syncProgress(
  completedStage: 5,
  soundEnabled: true,
  darkMode: true
);
```

#### Load Progress
```dart
final data = await LocalAuthService().loadProgress();
// Returns user's game data
```

## Advantages Over Backend

✅ **No Setup Required** - No Supabase project needed  
✅ **Always Works** - No server downtime  
✅ **Privacy** - Data never leaves device  
✅ **Fast** - No network latency  
✅ **Free** - No hosting costs  
✅ **Offline** - Works without internet  

## Limitations

⚠️ **No Cross-Device Sync** - Progress doesn't sync between phones/computers  
⚠️ **No Password Recovery** - Lost passwords cannot be reset  
⚠️ **No Cloud Backup** - Uninstalling app loses all data  
⚠️ **Device-Only** - Data tied to specific device  

## Migration from Supabase

If you previously used Supabase, all backend calls have been replaced:

| Old (Supabase) | New (Local Auth) |
|----------------|------------------|
| `SupabaseService()` | `LocalAuthService()` |
| `supabase.signUp()` | `authService.signUp()` |
| `supabase.signIn()` | `authService.signIn()` |
| `supabase.signOut()` | `authService.signOut()` |
| `supabase.syncProgress()` | `authService.syncProgress()` |

## Testing Accounts

You can create test accounts easily:

```dart
// Create test user
await LocalAuthService().signUp('test@example.com', 'password123');

// Sign in
await LocalAuthService().signIn('test@example.com', 'password123');
```

## Troubleshooting

**Problem**: User already exists error  
**Solution**: Use different email or sign in with existing account

**Problem**: Can't sign in after creating account  
**Solution**: Make sure you're using the exact same email and password

**Problem**: Progress not saving  
**Solution**: Make sure you're signed in (not playing as guest)

**Problem**: Lost password  
**Solution**: No recovery - create new account (local only limitation)

## Files Modified

- ✅ `lib/services/local_auth_service.dart` - New file (authentication)
- ✅ `lib/screens/auth_screen.dart` - Uses LocalAuthService
- ✅ `lib/providers/stage_provider.dart` - Uses LocalAuthService
- ✅ `lib/main.dart` - Initializes LocalAuthService
- ✅ `pubspec.yaml` - Added crypto package, removed supabase

## Next Steps

Your app is now fully functional with local authentication! 

🎮 **Ready to play without any backend setup!**

---

*For user-facing tutorial, see [USER_TUTORIAL.md](USER_TUTORIAL.md)*
