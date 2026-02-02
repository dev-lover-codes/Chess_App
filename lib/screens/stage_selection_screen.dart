import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stage_provider.dart';
import '../config/game_config.dart';
import 'game_screen.dart';

class StageSelectionScreen extends StatelessWidget {
  const StageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildStageGrid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Chess Master',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => _showSettings(context),
                icon: const Icon(Icons.settings),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<StageProvider>(
            builder: (context, stageProvider, child) {
              final completed = stageProvider.completedStages.length;
              return Text(
                'Progress: $completed/15 stages completed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStageGrid(BuildContext context) {
    return Consumer<StageProvider>(
      builder: (context, stageProvider, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            final stage = index + 1;
            final config = GameConfig.getStage(stage);
            final isUnlocked = stageProvider.isStageUnlocked(stage);
            final isCompleted = stageProvider.isStageCompleted(stage);

            return _buildStageCard(
              context,
              config,
              isUnlocked,
              isCompleted,
              stageProvider,
            );
          },
        );
      },
    );
  }

  Widget _buildStageCard(
    BuildContext context,
    StageConfig config,
    bool isUnlocked,
    bool isCompleted,
    StageProvider stageProvider,
  ) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: isUnlocked
            ? () {
                stageProvider.setCurrentStage(config.stage);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(stage: config.stage),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isCompleted
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.withOpacity(0.3),
                      Colors.orange.withOpacity(0.3),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.amber, size: 32)
              else if (!isUnlocked)
                const Icon(Icons.lock, color: Colors.grey, size: 32)
              else
                Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              const SizedBox(height: 8),
              Text(
                'Stage ${config.stage}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                config.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUnlocked ? null : Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                config.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isUnlocked ? Colors.grey[700] : Colors.grey,
                    ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<StageProvider>(
        builder: (context, stageProvider, child) {
          return AlertDialog(
            title: const Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Sound Effects'),
                  value: stageProvider.soundEnabled,
                  onChanged: (value) => stageProvider.toggleSound(),
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: stageProvider.darkMode,
                  onChanged: (value) => stageProvider.toggleDarkMode(),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Reset Progress'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmReset(context, stageProvider);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmReset(BuildContext context, StageProvider stageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will reset all your progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              stageProvider.resetProgress();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
