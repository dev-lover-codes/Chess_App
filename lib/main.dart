import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/stage_provider.dart';
import 'screens/home_screen.dart';
import 'services/local_auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Auth Service
  await LocalAuthService().initialize();

  // Load local progress
  final stageProvider = StageProvider();
  await stageProvider.loadProgress();
  
  runApp(ChessMasterApp(stageProvider: stageProvider));
}

class ChessMasterApp extends StatelessWidget {
  final StageProvider stageProvider;

  const ChessMasterApp({super.key, required this.stageProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: stageProvider,
      child: Consumer<StageProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Chess Master',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark, // Force dark mode for now to match design or use provider
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
