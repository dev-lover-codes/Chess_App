import 'package:flutter/material.dart';
import '../engine/piece.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;
  final Function(PieceType) onPieceSelected;

  const PromotionDialog({
    super.key,
    required this.color,
    required this.onPieceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final pieces = [
      (PieceType.queen, color == PieceColor.white ? '♕' : '♛'),
      (PieceType.rook, color == PieceColor.white ? '♖' : '♜'),
      (PieceType.bishop, color == PieceColor.white ? '♗' : '♝'),
      (PieceType.knight, color == PieceColor.white ? '♘' : '♞'),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Promote Pawn',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pieces.map((piece) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onPieceSelected(piece.$1);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        piece.$2,
                        style: const TextStyle(
                          fontSize: 40,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
