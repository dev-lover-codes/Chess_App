import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/stage_provider.dart';
import 'chess_board_painter.dart';

class ChessBoardWidget extends StatelessWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, StageProvider>(
      builder: (context, gameProvider, stageProvider, child) {
        final state = gameProvider.state;
        
        return AspectRatio(
          aspectRatio: 1.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth;
              
              return GestureDetector(
                onTapUp: (details) {
                  if (state.isAIThinking || state.isGameOver) return;
                  
                  final squareSize = size / 8;
                  final col = (details.localPosition.dx / squareSize).floor();
                  final row = (details.localPosition.dy / squareSize).floor();
                  
                  if (row >= 0 && row < 8 && col >= 0 && col < 8) {
                    gameProvider.selectSquare(row, col);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: ChessBoardPainter(
                      engine: state.engine,
                      selectedRow: state.selectedRow,
                      selectedCol: state.selectedCol,
                      legalMoves: state.legalMovesForSelected,
                      lastMove: state.lastMove,
                      isDarkMode: stageProvider.darkMode,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
