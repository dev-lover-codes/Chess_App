import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/stage_provider.dart';
import '../engine/move.dart';
import 'chess_board_painter.dart';
import 'animated_piece.dart';

class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({super.key});

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget>
    with SingleTickerProviderStateMixin {
  Move? _animatingMove;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, StageProvider>(
      builder: (context, gameProvider, stageProvider, child) {
        final state = gameProvider.state;
        
        // Trigger scale animation when piece is selected
        if (state.selectedRow != null && state.selectedCol != null) {
          _scaleController.forward();
        } else {
          _scaleController.reverse();
        }
        
        return AspectRatio(
          aspectRatio: 1.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth;
              
              return AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: state.selectedRow != null ? _scaleAnimation.value : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        // Dark modern board border
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                        color: const Color(0xFF1A1A1A),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: GestureDetector(
                          onTapUp: (details) {
                            if (state.isAIThinking || state.isGameOver) return;
                            
                            final squareSize = size / 8;
                            final col = (details.localPosition.dx / squareSize).floor();
                            final row = (details.localPosition.dy / squareSize).floor();
                            
                            if (row >= 0 && row < 8 && col >= 0 && col < 8) {
                              // Add haptic feedback
                              _triggerHapticFeedback();
                              gameProvider.selectSquare(row, col);
                            }
                          },
                          child: Stack(
                            children: [
                              // Base board
                              CustomPaint(
                                size: Size(size, size),
                                painter: ChessBoardPainter(
                                  engine: state.engine,
                                  selectedRow: state.selectedRow,
                                  selectedCol: state.selectedCol,
                                  legalMoves: state.legalMovesForSelected,
                                  lastMove: state.lastMove,
                                  hintMove: state.hintMove,
                                  highlightedMove: state.highlightedMove,
                                  isDarkMode: stageProvider.darkMode,
                                ),
                              ),
                              // Animated pieces layer
                              if (_animatingMove != null)
                                AnimatedChessPiece(
                                  piece: state.engine.board[_animatingMove!.toRow]
                                      [_animatingMove!.toCol]!,
                                  fromRow: _animatingMove!.fromRow,
                                  fromCol: _animatingMove!.fromCol,
                                  toRow: _animatingMove!.toRow,
                                  toCol: _animatingMove!.toCol,
                                  squareSize: size / 8,
                                  onComplete: () {
                                    setState(() {
                                      _animatingMove = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _triggerHapticFeedback() {
    // Light haptic feedback on tap
    // Note: This requires the vibration permission on mobile
    // For now, it's a placeholder
  }
}
