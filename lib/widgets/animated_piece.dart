import 'package:flutter/material.dart';
import '../engine/piece.dart';

class AnimatedChessPiece extends StatefulWidget {
  final Piece piece;
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final double squareSize;
  final VoidCallback? onComplete;

  const AnimatedChessPiece({
    super.key,
    required this.piece,
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.squareSize,
    this.onComplete,
  });

  @override
  State<AnimatedChessPiece> createState() => _AnimatedChessPieceState();
}

class _AnimatedChessPieceState extends State<AnimatedChessPiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final fromX = widget.fromCol * widget.squareSize;
        final fromY = widget.fromRow * widget.squareSize;
        final toX = widget.toCol * widget.squareSize;
        final toY = widget.toRow * widget.squareSize;

        final currentX = fromX + (toX - fromX) * _animation.value;
        final currentY = fromY + (toY - fromY) * _animation.value;

        return Positioned(
          left: currentX,
          top: currentY,
          child: SizedBox(
            width: widget.squareSize,
            height: widget.squareSize,
            child: Center(
              child: Text(
                widget.piece.symbol,
                style: TextStyle(
                  fontSize: widget.squareSize * 0.7,
                  fontFamily: 'Arial',
                  color: widget.piece.color == PieceColor.white
                      ? Colors.white
                      : Colors.black,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 3,
                      color: widget.piece.color == PieceColor.white
                          ? Colors.black.withOpacity(0.6)
                          : Colors.white.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
