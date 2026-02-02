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
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stage ${widget.stage} - ${GameConfig.getStage(widget.stage).name}'),
          actions: [
            IconButton(
              onPressed: () => _showHint(),
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: 'Hint',
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isPortrait = constraints.maxHeight > constraints.maxWidth;
              
              return isPortrait
                  ? _buildPortraitLayout()
                  : _buildLandscapeLayout();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildStatusBar(),
        Expanded(
          flex: 3,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const ChessBoardWidget(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildControls(),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Move History',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const Divider(height: 1),
                      const Expanded(child: MoveHistoryWidget()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildStatusBar(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: const ChessBoardWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildControls(),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Move History',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const Divider(height: 1),
                      const Expanded(child: MoveHistoryWidget()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final state = gameProvider.state;
        String statusText = '';
        Color? statusColor;

        if (state.isAIThinking) {
          statusText = 'AI is thinking...';
          statusColor = Colors.orange;
        } else if (state.status == GameStatus.check) {
          statusText = 'Check!';
          statusColor = Colors.red;
        } else if (state.status == GameStatus.checkmate) {
          statusText = state.isPlayerTurn ? 'Checkmate - You Lost' : 'Checkmate - You Won!';
          statusColor = state.isPlayerTurn ? Colors.red : Colors.green;
        } else if (state.status == GameStatus.stalemate) {
          statusText = 'Stalemate - Draw';
          statusColor = Colors.grey;
        } else if (state.status == GameStatus.draw) {
          statusText = 'Draw';
          statusColor = Colors.grey;
        } else {
          statusText = state.isPlayerTurn ? 'Your Turn (White)' : 'AI Turn (Black)';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: statusColor?.withOpacity(0.2),
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final config = GameConfig.getStage(widget.stage);
        final canUndo = gameProvider.state.canUndo &&
            (config.undoLimit == null ||
                gameProvider.state.engine.moveHistory.length <= (config.undoLimit! * 2));

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  gameProvider.resetGame();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart'),
              ),
              ElevatedButton.icon(
                onPressed: canUndo
                    ? () {
                        gameProvider.undoMove();
                      }
                    : null,
                icon: const Icon(Icons.undo),
                label: const Text('Undo'),
              ),
            ],
          ),
        );
      },
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
