import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/stage_provider.dart';
import 'screens/stage_selection_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
            themeMode: provider.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const ChessMasterHome(),
          );
        },
      ),
    );
  }
}

class ChessMasterHome extends StatelessWidget {
  const ChessMasterHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const StageSelectionScreen();
  }
}
