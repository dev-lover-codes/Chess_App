import 'package:flutter/material.dart';
import '../engine/chess_engine.dart';
import '../engine/piece.dart';
import '../engine/move.dart';
import '../theme/app_theme.dart';

class ChessBoardPainter extends CustomPainter {
  final ChessEngine engine;
  final int? selectedRow;
  final int? selectedCol;
  final List<Move> legalMoves;
  final Move? lastMove;
  final bool isDarkMode;
  final bool showCoordinates;

  ChessBoardPainter({
    required this.engine,
    this.selectedRow,
    this.selectedCol,
    this.legalMoves = const [],
    this.lastMove,
    this.isDarkMode = false,
    this.showCoordinates = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;

    // Draw board squares
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final rect = Rect.fromLTWH(
          col * squareSize,
          row * squareSize,
          squareSize,
          squareSize,
        );

        // Determine square color
        Color squareColor;
        final isLight = (row + col) % 2 == 0;
        
        if (isDarkMode) {
          squareColor = isLight ? AppTheme.lightSquareDark : AppTheme.darkSquareDark;
        } else {
          squareColor = isLight ? AppTheme.lightSquare : AppTheme.darkSquare;
        }

        // Highlight last move
        if (lastMove != null &&
            ((lastMove!.fromRow == row && lastMove!.fromCol == col) ||
                (lastMove!.toRow == row && lastMove!.toCol == col))) {
          squareColor = isDarkMode
              ? AppTheme.lastMoveHighlightDark
              : AppTheme.lastMoveHighlight;
        }

        // Highlight selected square
        if (selectedRow == row && selectedCol == col) {
          squareColor = isDarkMode
              ? AppTheme.selectedSquareDark
              : AppTheme.selectedSquare;
        }

        // Check if king is in check
        final piece = engine.board[row][col];
        if (piece != null && piece.type == PieceType.king) {
          final status = engine.getGameStatus();
          if (status == GameStatus.check && piece.color == engine.currentTurn) {
            squareColor = isDarkMode
                ? AppTheme.checkHighlightDark
                : AppTheme.checkHighlight;
          }
        }

        canvas.drawRect(rect, Paint()..color = squareColor);
      }
    }

    // Draw legal move indicators
    for (final move in legalMoves) {
      final centerX = (move.toCol + 0.5) * squareSize;
      final centerY = (move.toRow + 0.5) * squareSize;
      final radius = squareSize * 0.15;

      final paint = Paint()
        ..color = isDarkMode
            ? AppTheme.legalMoveIndicatorDark
            : AppTheme.legalMoveIndicator
        ..style = PaintingStyle.fill;

      // Draw circle for empty squares, ring for captures
      if (move.capturedPiece != null) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = squareSize * 0.1;
        canvas.drawCircle(Offset(centerX, centerY), squareSize * 0.4, paint);
      } else {
        canvas.drawCircle(Offset(centerX, centerY), radius, paint);
      }
    }

    // Draw pieces
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = engine.board[row][col];
        if (piece != null) {
          _drawPiece(
            canvas,
            piece,
            col * squareSize,
            row * squareSize,
            squareSize,
          );
        }
      }
    }

    // Draw coordinates
    if (showCoordinates) {
      _drawCoordinates(canvas, size, squareSize);
    }
  }

  void _drawPiece(Canvas canvas, Piece piece, double x, double y, double size) {
    final textStyle = TextStyle(
      fontSize: size * 0.7,
      fontFamily: 'Arial',
      color: piece.color == PieceColor.white ? Colors.white : Colors.black,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 2,
          color: piece.color == PieceColor.white ? Colors.black54 : Colors.white54,
        ),
      ],
    );

    final textSpan = TextSpan(
      text: piece.symbol,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offsetX = x + (size - textPainter.width) / 2;
    final offsetY = y + (size - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(offsetX, offsetY));
  }

  void _drawCoordinates(Canvas canvas, Size size, double squareSize) {
    final textStyle = TextStyle(
      fontSize: squareSize * 0.2,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white70 : Colors.black54,
    );

    // Draw file letters (a-h)
    for (int col = 0; col < 8; col++) {
      final letter = String.fromCharCode(97 + col);
      final textSpan = TextSpan(text: letter, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final x = col * squareSize + squareSize - textPainter.width - 2;
      final y = size.height - textPainter.height - 2;
      textPainter.paint(canvas, Offset(x, y));
    }

    // Draw rank numbers (1-8)
    for (int row = 0; row < 8; row++) {
      final number = (8 - row).toString();
      final textSpan = TextSpan(text: number, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final x = 2.0;
      final y = row * squareSize + 2;
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(ChessBoardPainter oldDelegate) {
    return oldDelegate.engine != engine ||
        oldDelegate.selectedRow != selectedRow ||
        oldDelegate.selectedCol != selectedCol ||
        oldDelegate.legalMoves != legalMoves ||
        oldDelegate.lastMove != lastMove ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
