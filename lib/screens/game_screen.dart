import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/stage_provider.dart';
import '../services/audio_service.dart';
import '../config/game_config.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/promotion_dialog.dart';
import '../widgets/game_result_dialog.dart';
import '../engine/piece.dart';
import '../theme/app_theme.dart';

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
        backgroundColor: AppTheme.darkBackground,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu, color: Colors.white70)),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none, color: Colors.white70)),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 2. Opponent Profile
              _buildProfileCard(
                name: "Calvin McDaniel",
                title: "Jazz player", // Placeholder
                isOpponent: true,
              ),

              const Spacer(),

              // 3. Chess Board
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<GameProvider>(
                  builder: (context, provider, _) { 
                    // Use a Container with transform for 'perspective' look if needed
                    // For now, standard board but styled cleanly
                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                           BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 50,
                            offset: const Offset(0, 20),
                            spreadRadius: 0
                           )
                        ]
                      ),
                      child: const ChessBoardWidget()
                    );
                  }
                ),
              ),

              const Spacer(),

              // 4. Player Profile & Actions
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(32),
                   border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    // Player Info
                     Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage("https://i.pravatar.cc/150?u=david"), // Placeholder
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "David Moody",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Ordinary player",
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons (Chat, Stats, Notes, Flag)
                    Theme(
                      data: ThemeData.dark(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           _buildActionButton(Icons.chat_bubble_outline),
                           _buildActionButton(Icons.show_chart),
                           _buildActionButton(Icons.assignment_outlined),
                           _buildActionButton(Icons.flag_outlined, color: Colors.red.withOpacity(0.7)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({required String name, required String title, bool isOpponent = false}) {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 24.0),
       child: Row(
        mainAxisAlignment: isOpponent ? MainAxisAlignment.center : MainAxisAlignment.start,
         children: [
            // Simplified opponent view for now to match top part of design
            if (isOpponent)
               Expanded(
                 child: Column(
                   children: [
                     Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: NetworkImage("https://i.pravatar.cc/150?u=calvin"), // Placeholder
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      Text(
                          name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                   ],
                 ),
               ),
         ],
       ),
     );
  }

  Widget _buildActionButton(IconData icon, {Color? color}) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, color: color ?? Colors.white54, size: 22),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent, // Or minimal background
      ),
    );
  }
}
