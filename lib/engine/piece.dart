// Chess piece types
enum PieceType {
  pawn,
  knight,
  bishop,
  rook,
  queen,
  king,
}

// Piece colors
enum PieceColor {
  white,
  black,
}

// Chess piece representation
class Piece {
  final PieceType type;
  final PieceColor color;

  const Piece(this.type, this.color);

  // Unicode symbols for chess pieces
  String get symbol {
    const symbols = {
      PieceType.king: {'white': '♔', 'black': '♚'},
      PieceType.queen: {'white': '♕', 'black': '♛'},
      PieceType.rook: {'white': '♖', 'black': '♜'},
      PieceType.bishop: {'white': '♗', 'black': '♝'},
      PieceType.knight: {'white': '♘', 'black': '♞'},
      PieceType.pawn: {'white': '♙', 'black': '♟'},
    };
    return symbols[type]![color == PieceColor.white ? 'white' : 'black']!;
  }

  // Piece values for evaluation
  int get value {
    switch (type) {
      case PieceType.pawn:
        return 100;
      case PieceType.knight:
        return 320;
      case PieceType.bishop:
        return 330;
      case PieceType.rook:
        return 500;
      case PieceType.queen:
        return 900;
      case PieceType.king:
        return 20000;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Piece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;

  @override
  String toString() => symbol;
}
