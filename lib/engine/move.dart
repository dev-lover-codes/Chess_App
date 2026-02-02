import 'piece.dart';

// Chess move representation
class Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final Piece? promotionPiece;
  final bool isEnPassant;
  final bool isCastling;
  final Piece? capturedPiece;

  const Move({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.promotionPiece,
    this.isEnPassant = false,
    this.isCastling = false,
    this.capturedPiece,
  });

  // Convert to algebraic notation (e.g., "e2e4")
  String toAlgebraic() {
    final from = _squareToAlgebraic(fromRow, fromCol);
    final to = _squareToAlgebraic(toRow, toCol);
    if (promotionPiece != null) {
      return '$from$to${_pieceToChar(promotionPiece!)}';
    }
    return '$from$to';
  }

  // Convert to standard notation (e.g., "e4", "Nf3", "O-O")
  String toStandardNotation(List<List<Piece?>> board) {
    if (isCastling) {
      return toCol > fromCol ? 'O-O' : 'O-O-O';
    }

    final piece = board[fromRow][fromCol]!;
    final pieceChar = piece.type == PieceType.pawn ? '' : _pieceToChar(piece).toUpperCase();
    final capture = capturedPiece != null ? 'x' : '';
    final destination = _squareToAlgebraic(toRow, toCol);
    
    if (piece.type == PieceType.pawn && capturedPiece != null) {
      return '${String.fromCharCode(97 + fromCol)}$capture$destination';
    }
    
    if (promotionPiece != null) {
      return '$destination=${_pieceToChar(promotionPiece!).toUpperCase()}';
    }
    
    return '$pieceChar$capture$destination';
  }

  String _squareToAlgebraic(int row, int col) {
    final file = String.fromCharCode(97 + col); // a-h
    final rank = (8 - row).toString(); // 1-8
    return '$file$rank';
  }

  String _pieceToChar(Piece piece) {
    switch (piece.type) {
      case PieceType.king:
        return 'k';
      case PieceType.queen:
        return 'q';
      case PieceType.rook:
        return 'r';
      case PieceType.bishop:
        return 'b';
      case PieceType.knight:
        return 'n';
      case PieceType.pawn:
        return 'p';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Move &&
          fromRow == other.fromRow &&
          fromCol == other.fromCol &&
          toRow == other.toRow &&
          toCol == other.toCol &&
          promotionPiece == other.promotionPiece;

  @override
  int get hashCode =>
      fromRow.hashCode ^
      fromCol.hashCode ^
      toRow.hashCode ^
      toCol.hashCode ^
      promotionPiece.hashCode;

  @override
  String toString() => toAlgebraic();
}
