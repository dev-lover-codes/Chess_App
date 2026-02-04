import 'dart:math';
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
  final Move? hintMove; // Show hint visually
  final Move? highlightedMove; // Show clicked history move
  final bool isDarkMode;
  final bool showCoordinates;

  ChessBoardPainter({
    required this.engine,
    this.selectedRow,
    this.selectedCol,
    this.legalMoves = const [],
    this.lastMove,
    this.hintMove,
    this.highlightedMove,
    this.isDarkMode = false,
    this.showCoordinates = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;

    // Draw board with gradient effect
    _drawBoardWithGradient(canvas, size, squareSize);

    // Draw hint or highlighted move with GREEN dots
    _drawHintOrHighlightedMove(canvas, squareSize);

    // Draw legal move indicators
    _drawLegalMoveIndicators(canvas, squareSize);

    // Draw pieces with shadows
    _drawPiecesWithShadows(canvas, squareSize);

    // Draw coordinates
    if (showCoordinates) {
      _drawCoordinates(canvas, size, squareSize);
    }
  }

  void _drawHintOrHighlightedMove(Canvas canvas, double squareSize) {
    final moveToShow = hintMove ?? highlightedMove;
    if (moveToShow == null) return;

    // Draw GREEN path from source to destination
    final fromX = (moveToShow.fromCol + 0.5) * squareSize;
    final fromY = (moveToShow.fromRow + 0.5) * squareSize;
    final toX = (moveToShow.toCol + 0.5) * squareSize;
    final toY = (moveToShow.toRow + 0.5) * squareSize;

    // Draw green glow on source square
    final fromRect = Rect.fromLTWH(
      moveToShow.fromCol * squareSize,
      moveToShow.fromRow * squareSize,
      squareSize,
      squareSize,
    );
    final fromGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.green.withOpacity(0.4),
          Colors.green.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(fromRect);
    canvas.drawRect(fromRect, fromGlowPaint);

    // Draw green glow on destination square
    final toRect = Rect.fromLTWH(
      moveToShow.toCol * squareSize,
      moveToShow.toRow * squareSize,
      squareSize,
      squareSize,
    );
    final toGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.green.withOpacity(0.5),
          Colors.green.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(toRect);
    canvas.drawRect(toRect, toGlowPaint);

    // Draw GREEN dots on source and destination
    final greenPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Source dot with glow
    final sourceGlowPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(fromX, fromY), squareSize * 0.25, sourceGlowPaint);
    canvas.drawCircle(Offset(fromX, fromY), squareSize * 0.2, greenPaint);

    // Destination dot with glow (larger)
    final destGlowPaint = Paint()
      ..color = Colors.green.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(toX, toY), squareSize * 0.35, destGlowPaint);
    canvas.drawCircle(Offset(toX, toY), squareSize * 0.28, greenPaint);

    // Draw arrow from source to destination
    final arrowPaint = Paint()
      ..color = Colors.green.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(fromX, fromY), Offset(toX, toY), arrowPaint);

    // Draw arrowhead
    final angle = atan2(toY - fromY, toX - fromX);
    final arrowSize = squareSize * 0.2;
    final arrowPath = Path();
    arrowPath.moveTo(toX, toY);
    arrowPath.lineTo(
      toX - arrowSize * cos(angle - 0.5),
      toY - arrowSize * sin(angle - 0.5),
    );
    arrowPath.lineTo(
      toX - arrowSize * cos(angle + 0.5),
      toY - arrowSize * sin(angle + 0.5),
    );
    arrowPath.close();
    
    final arrowFillPaint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowFillPaint);
  }

  void _drawBoardWithGradient(Canvas canvas, Size size, double squareSize) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final rect = Rect.fromLTWH(
          col * squareSize,
          row * squareSize,
          squareSize,
          squareSize,
        );

        // Determine base square color
        Color squareColor;
        final isLight = (row + col) % 2 == 0;
        
        // Use design defined colors
        if (isDarkMode) {
          // Use specific colors from the design image (approximated)
          squareColor = isLight ? const Color(0xFFE8E8E8) : const Color(0xFFC0C5CF); // Lighter blue-grey for dark squares, almost white for light
          // Actually looking at the image:
          // Dark squares are distinct blue-ish grey (#50597b maybe?), Light squares are white
          squareColor = isLight ? Colors.white : const Color(0xFF777F99);
        } else {
           squareColor = isLight ? Colors.white : const Color(0xFF777F99);
        }

        final paint = Paint()..color = squareColor;
        canvas.drawRect(rect, paint);

        // Highlight last move with subtle glow
        if (lastMove != null &&
            ((lastMove!.fromRow == row && lastMove!.fromCol == col) ||
                (lastMove!.toRow == row && lastMove!.toCol == col))) {
           final highlightColor = Colors.yellow.withOpacity(0.4);
          
          final glowPaint = Paint()
            ..color = highlightColor;
          canvas.drawRect(rect, glowPaint);
        }

        // Highlight selected square
        if (selectedRow == row && selectedCol == col) {
           final selectedColor = const Color(0xFF6C63FF).withOpacity(0.5); // Purple highlight
          
          final paint = Paint()
            ..color = selectedColor
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect, paint);
        }

        // Check if king is in check - add red glow
        final piece = engine.board[row][col];
        if (piece != null && piece.type == PieceType.king) {
          final status = engine.getGameStatus();
          if (status == GameStatus.check && piece.color == engine.currentTurn) {
             final checkColor = Colors.red.withOpacity(0.5);
            
            final glowPaint = Paint()
              ..shader = RadialGradient(
                center: Alignment.center,
                colors: [
                  checkColor,
                  checkColor.withOpacity(0.3),
                  Colors.transparent,
                ],
              ).createShader(rect);
            canvas.drawRect(rect, glowPaint);
          }
        }
      }
    }
  }

  void _drawLegalMoveIndicators(Canvas canvas, double squareSize) {
    for (final move in legalMoves) {
      final centerX = (move.toCol + 0.5) * squareSize;
      final centerY = (move.toRow + 0.5) * squareSize;

      final paint = Paint()
        ..color = isDarkMode
            ? AppTheme.legalMoveIndicatorDark
            : AppTheme.legalMoveIndicator
        ..style = PaintingStyle.fill;

      // Draw circle for empty squares, ring for captures
      if (move.capturedPiece != null) {
        // Capture indicator - ring with glow
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = squareSize * 0.12;
        
        // Outer glow
        final glowPaint = Paint()
          ..color = paint.color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = squareSize * 0.18
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(centerX, centerY), squareSize * 0.38, glowPaint);
        
        // Main ring
        canvas.drawCircle(Offset(centerX, centerY), squareSize * 0.38, paint);
      } else {
        // Normal move indicator - dot with shadow
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(
          Offset(centerX + 1, centerY + 1),
          squareSize * 0.15,
          shadowPaint,
        );
        
        canvas.drawCircle(Offset(centerX, centerY), squareSize * 0.15, paint);
      }
    }
  }

  void _drawPiecesWithShadows(Canvas canvas, double squareSize) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = engine.board[row][col];
        if (piece != null) {
          _drawPieceWithShadow(
            canvas,
            piece,
            col * squareSize,
            row * squareSize,
            squareSize,
          );
        }
      }
    }
  }

  void _drawPieceWithShadow(
    Canvas canvas,
    Piece piece,
    double x,
    double y,
    double size,
  ) {
    final textStyle = TextStyle(
      fontSize: size * 0.75,
      fontFamily: 'Arial',
      color: piece.color == PieceColor.white ? Colors.white : Colors.black,
      shadows: [
        Shadow(
          offset: const Offset(2, 2),
          blurRadius: 4,
          color: piece.color == PieceColor.white
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.7),
        ),
        Shadow(
          offset: const Offset(-1, -1),
          blurRadius: 2,
          color: piece.color == PieceColor.white
              ? Colors.white.withOpacity(0.3)
              : Colors.black.withOpacity(0.3),
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
      fontSize: squareSize * 0.22,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.6),
      shadows: [
        Shadow(
          offset: const Offset(0.5, 0.5),
          blurRadius: 1,
          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
        ),
      ],
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

      final x = col * squareSize + squareSize - textPainter.width - 4;
      final y = size.height - textPainter.height - 4;
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

      final x = 4.0;
      final y = row * squareSize + 4;
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
        oldDelegate.hintMove != hintMove ||
        oldDelegate.highlightedMove != highlightedMove ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
