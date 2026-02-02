import '../engine/chess_engine.dart';
import '../engine/piece.dart';

// Position evaluator for AI
class Evaluator {
  // Piece-square tables for positional evaluation
  static const List<List<int>> pawnTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  static const List<List<int>> knightTable = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50],
  ];

  static const List<List<int>> bishopTable = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20],
  ];

  static const List<List<int>> rookTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [0, 0, 0, 5, 5, 0, 0, 0],
  ];

  static const List<List<int>> queenTable = [
    [-20, -10, -10, -5, -5, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 5, 5, 5, 0, -10],
    [-5, 0, 5, 5, 5, 5, 0, -5],
    [0, 0, 5, 5, 5, 5, 0, -5],
    [-10, 5, 5, 5, 5, 5, 0, -10],
    [-10, 0, 5, 0, 0, 0, 0, -10],
    [-20, -10, -10, -5, -5, -10, -10, -20],
  ];

  static const List<List<int>> kingMiddleGameTable = [
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [20, 30, 10, 0, 0, 10, 30, 20],
  ];

  static const List<List<int>> kingEndGameTable = [
    [-50, -40, -30, -20, -20, -30, -40, -50],
    [-30, -20, -10, 0, 0, -10, -20, -30],
    [-30, -10, 20, 30, 30, 20, -10, -30],
    [-30, -10, 30, 40, 40, 30, -10, -30],
    [-30, -10, 30, 40, 40, 30, -10, -30],
    [-30, -10, 20, 30, 30, 20, -10, -30],
    [-30, -30, 0, 0, 0, 0, -30, -30],
    [-50, -30, -30, -30, -30, -30, -30, -50],
  ];

  // Evaluate position from white's perspective
  static int evaluate(ChessEngine engine, {bool usePositional = true}) {
    int score = 0;

    // Count material
    int whiteMaterial = 0;
    int blackMaterial = 0;
    int totalPieces = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = engine.board[row][col];
        if (piece == null) continue;

        totalPieces++;
        final materialValue = piece.value;

        if (piece.color == PieceColor.white) {
          whiteMaterial += materialValue;
          if (usePositional) {
            score += _getPositionalValue(piece, row, col, totalPieces < 16);
          }
        } else {
          blackMaterial += materialValue;
          if (usePositional) {
            score -= _getPositionalValue(piece, 7 - row, col, totalPieces < 16);
          }
        }
      }
    }

    score += whiteMaterial - blackMaterial;

    // Mobility bonus (number of legal moves)
    if (usePositional) {
      final currentTurn = engine.currentTurn;
      final whiteMoves = currentTurn == PieceColor.white
          ? engine.getLegalMoves().length
          : 0;
      engine.currentTurn = PieceColor.white;
      final whiteMovesCount = currentTurn == PieceColor.white ? whiteMoves : engine.getLegalMoves().length;
      engine.currentTurn = PieceColor.black;
      final blackMovesCount = engine.getLegalMoves().length;
      engine.currentTurn = currentTurn;

      score += (whiteMovesCount - blackMovesCount) * 2;
    }

    return score;
  }

  static int _getPositionalValue(Piece piece, int row, int col, bool isEndgame) {
    switch (piece.type) {
      case PieceType.pawn:
        return pawnTable[row][col];
      case PieceType.knight:
        return knightTable[row][col];
      case PieceType.bishop:
        return bishopTable[row][col];
      case PieceType.rook:
        return rookTable[row][col];
      case PieceType.queen:
        return queenTable[row][col];
      case PieceType.king:
        return isEndgame ? kingEndGameTable[row][col] : kingMiddleGameTable[row][col];
    }
  }

  // Evaluate material only (for simpler AI levels)
  static int evaluateMaterial(ChessEngine engine) {
    return evaluate(engine, usePositional: false);
  }
}
