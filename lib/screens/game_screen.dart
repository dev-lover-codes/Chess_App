import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/stage_provider.dart';
import '../services/audio_service.dart';
import '../config/game_config.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/move_history_widget.dart';
import '../widgets/promotion_dialog.dart';
import '../widgets/game_result_dialog.dart';
import '../engine/piece.dart';
import '../engine/chess_engine.dart';

class GameScreen extends StatefulWidget {
  final int stage;

  const GameScreen({super.key, required this.stage});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider _gameProvider;
  final AudioService _audio = AudioService();
  int? _promotionRow;
  int? _promotionCol;

  @override
  void initState() {
    super.initState();
    _gameProvider = GameProvider(
      stage: widget.stage,
      onGameEvent: _handleGameEvent,
    );
    
    // Start AI move if AI plays first (not in this game, but for future)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameProvider.startAIMove();
    });
  }

  void _handleGameEvent(String event) {
    final stageProvider = Provider.of<StageProvider>(context, listen: false);
    
    if (!stageProvider.soundEnabled) return;

    if (event == 'move') {
      _audio.playMove();
    } else if (event == 'capture') {
      _audio.playCapture();
    } else if (event == 'check') {
      _audio.playCheck();
    } else if (event == 'checkmate') {
      _audio.playCheckmate();
    } else if (event == 'player_won') {
      _showGameResult(true, false);
      stageProvider.completeStage(widget.stage);
      _audio.playVictory();
    } else if (event == 'ai_won') {
      _showGameResult(false, false);
    } else if (event == 'draw') {
      _showGameResult(false, true);
    } else if (event.startsWith('promotion_needed:')) {
      final parts = event.split(':');
      _promotionRow = int.parse(parts[1]);
      _promotionCol = int.parse(parts[2]);
      _showPromotionDialog();
    }
  }

  void _showPromotionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PromotionDialog(
        color: PieceColor.white,
        onPieceSelected: (type) {
          if (_promotionRow != null && _promotionCol != null) {
            _gameProvider.makePromotionMove(_promotionRow!, _promotionCol!, type);
            _promotionRow = null;
            _promotionCol = null;
          }
        },
      ),
    );
  }

  void _showGameResult(bool isVictory, bool isDraw) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final hasNextStage = widget.stage < GameConfig.stages.length;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GameResultDialog(
          title: isDraw
              ? 'Draw!'
              : isVictory
                  ? 'Victory!'
                  : 'Defeat',
          message: isDraw
              ? 'The game ended in a draw.'
              : isVictory
                  ? 'Congratulations! You won this stage!'
                  : 'Better luck next time!',
          isVictory: isVictory,
          onPlayAgain: () {
            Navigator.pop(context);
            _gameProvider.resetGame();
          },
          onBackToMenu: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          onNextStage: (isVictory && hasNextStage) 
              ? () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(stage: widget.stage + 1),
                    ),
                  );
                }
              : null,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameProvider,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildGlassIconBtn(
              icon: Icons.arrow_back_ios_new,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          centerTitle: true,
          title: _buildGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Stage ${widget.stage}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildGlassIconBtn(
                icon: Icons.history,
                onPressed: _showHistorySheet,
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // 1. Board Centered
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const ChessBoardWidget(),
                  ),
                ),

                // 2. Info Panel (Floating Top)
                Positioned(
                  top: 10,
                  left: 20,
                  right: 20,
                  child: _buildInfoPanel(),
                ),

                // 3. Controls (Floating Bottom)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: _buildFloatingControls(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
  
  Widget _buildGlassIconBtn({required IconData icon, required VoidCallback onPressed}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          child: IconButton(
            icon: Icon(icon, size: 20),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final state = gameProvider.state;
        String statusText;
        Color statusColor = Theme.of(context).colorScheme.onSurface;
        IconData statusIcon = Icons.info_outline;

        if (state.isAIThinking) {
          statusText = 'AI Thinking...';
          statusIcon = Icons.psychology;
        } else if (state.status == GameStatus.check) {
          statusText = 'Check!';
          statusColor = Colors.red;
          statusIcon = Icons.warning_amber_rounded;
        } else if (state.status == GameStatus.checkmate) {
          statusText = state.isPlayerTurn ? 'Defeat' : 'Victory!';
          statusColor = state.isPlayerTurn ? Colors.red : Colors.green;
          statusIcon = Icons.emoji_events;
        } else {
          statusText = state.isPlayerTurn ? 'Your Turn' : 'Opponent\'s Turn';
          statusIcon = state.isPlayerTurn ? Icons.person : Icons.computer;
        }

        return _buildGlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor),
              const SizedBox(width: 10),
              Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: statusColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingControls() {
    return _buildGlassContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.undo,
            label: 'Undo',
            onPressed: _gameProvider.state.canUndo ? _gameProvider.undoMove : null,
          ),
           _buildControlButton(
             icon: Icons.lightbulb_outline,
            label: 'Hint',
            onPressed: () => _showHint(),
           ),
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Restart',
            onPressed: _gameProvider.resetGame,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, VoidCallback? onPressed}) {
    final isEnabled = onPressed != null;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Move History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Expanded(child: MoveHistoryWidget()),
          ],
        ),
      ),
    );
  }

  Future<void> _showHint() async {
    final config = GameConfig.getStage(widget.stage);
    if (!config.hintsAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Hints are not allowed in this stage')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Calculating best move...'),
          ],
        ),
        duration: const Duration(seconds: 10),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final hint = await _gameProvider.getHint();
    
    // Clear loading snackbar
    ScaffoldMessenger.of(context).clearSnackBars();
    
    if (hint != null && mounted) {
      // Show hint VISUALLY on the board with green arrow
      _gameProvider.showHintOnBoard(hint);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hint shown on board!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Move: ${hint.toAlgebraic()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Clear',
            textColor: Colors.white,
            onPressed: () {
              _gameProvider.clearHint();
            },
          ),
        ),
      );
      
      // Auto-clear hint after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _gameProvider.clearHint();
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('No hint available')),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _gameProvider.dispose();
    super.dispose();
  }
}
