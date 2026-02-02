import 'piece.dart';
import 'move.dart';

// Game status
enum GameStatus {
  playing,
  check,
  checkmate,
  stalemate,
  draw,
}

// Chess engine with complete rule implementation
class ChessEngine {
  // 8x8 board (row 0 = rank 8, row 7 = rank 1)
  List<List<Piece?>> board = List.generate(8, (_) => List.filled(8, null));
  
  PieceColor currentTurn = PieceColor.white;
  
  // Castling rights
  bool whiteKingsideCastle = true;
  bool whiteQueensideCastle = true;
  bool blackKingsideCastle = true;
  bool blackQueensideCastle = true;
  
  // En passant target square
  int? enPassantRow;
  int? enPassantCol;
  
  // Move counters
  int halfMoveClock = 0; // For 50-move rule
  int fullMoveNumber = 1;
  
  // Move history
  List<Move> moveHistory = [];
  
  // Position history for threefold repetition
  List<String> positionHistory = [];

  ChessEngine() {
    _setupInitialPosition();
  }

  void _setupInitialPosition() {
    // Black pieces (row 0 = rank 8)
    board[0] = [
      const Piece(PieceType.rook, PieceColor.black),
      const Piece(PieceType.knight, PieceColor.black),
      const Piece(PieceType.bishop, PieceColor.black),
      const Piece(PieceType.queen, PieceColor.black),
      const Piece(PieceType.king, PieceColor.black),
      const Piece(PieceType.bishop, PieceColor.black),
      const Piece(PieceType.knight, PieceColor.black),
      const Piece(PieceType.rook, PieceColor.black),
    ];
    
    // Black pawns (row 1 = rank 7)
    board[1] = List.generate(8, (_) => const Piece(PieceType.pawn, PieceColor.black));
    
    // Empty squares
    for (int i = 2; i < 6; i++) {
      board[i] = List.filled(8, null);
    }
    
    // White pawns (row 6 = rank 2)
    board[6] = List.generate(8, (_) => const Piece(PieceType.pawn, PieceColor.white));
    
    // White pieces (row 7 = rank 1)
    board[7] = [
      const Piece(PieceType.rook, PieceColor.white),
      const Piece(PieceType.knight, PieceColor.white),
      const Piece(PieceType.bishop, PieceColor.white),
      const Piece(PieceType.queen, PieceColor.white),
      const Piece(PieceType.king, PieceColor.white),
      const Piece(PieceType.bishop, PieceColor.white),
      const Piece(PieceType.knight, PieceColor.white),
      const Piece(PieceType.rook, PieceColor.white),
    ];
    
    positionHistory.add(_getBoardHash());
  }

  // Get all legal moves for the current player
  List<Move> getLegalMoves() {
    List<Move> moves = [];
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == currentTurn) {
          moves.addAll(getLegalMovesForPiece(row, col));
        }
      }
    }
    
    return moves;
  }

  // Get legal moves for a specific piece
  List<Move> getLegalMovesForPiece(int row, int col) {
    final piece = board[row][col];
    if (piece == null || piece.color != currentTurn) return [];
    
    List<Move> pseudoLegalMoves = [];
    
    switch (piece.type) {
      case PieceType.pawn:
        pseudoLegalMoves = _getPawnMoves(row, col, piece.color);
        break;
      case PieceType.knight:
        pseudoLegalMoves = _getKnightMoves(row, col, piece.color);
        break;
      case PieceType.bishop:
        pseudoLegalMoves = _getBishopMoves(row, col, piece.color);
        break;
      case PieceType.rook:
        pseudoLegalMoves = _getRookMoves(row, col, piece.color);
        break;
      case PieceType.queen:
        pseudoLegalMoves = _getQueenMoves(row, col, piece.color);
        break;
      case PieceType.king:
        pseudoLegalMoves = _getKingMoves(row, col, piece.color);
        break;
    }
    
    // Filter out moves that leave king in check
    return pseudoLegalMoves.where((move) => !_leavesKingInCheck(move)).toList();
  }

  List<Move> _getPawnMoves(int row, int col, PieceColor color) {
    List<Move> moves = [];
    final direction = color == PieceColor.white ? -1 : 1;
    final startRow = color == PieceColor.white ? 6 : 1;
    final promotionRow = color == PieceColor.white ? 0 : 7;
    
    // Forward move
    final newRow = row + direction;
    if (_isValidSquare(newRow, col) && board[newRow][col] == null) {
      if (newRow == promotionRow) {
        // Promotion
        for (final type in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
          moves.add(Move(
            fromRow: row,
            fromCol: col,
            toRow: newRow,
            toCol: col,
            promotionPiece: Piece(type, color),
          ));
        }
      } else {
        moves.add(Move(fromRow: row, fromCol: col, toRow: newRow, toCol: col));
        
        // Double move from starting position
        if (row == startRow) {
          final doubleRow = row + 2 * direction;
          if (board[doubleRow][col] == null) {
            moves.add(Move(fromRow: row, fromCol: col, toRow: doubleRow, toCol: col));
          }
        }
      }
    }
    
    // Captures
    for (final colOffset in [-1, 1]) {
      final captureCol = col + colOffset;
      if (_isValidSquare(newRow, captureCol)) {
        final target = board[newRow][captureCol];
        if (target != null && target.color != color) {
          if (newRow == promotionRow) {
            // Promotion with capture
            for (final type in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
              moves.add(Move(
                fromRow: row,
                fromCol: col,
                toRow: newRow,
                toCol: captureCol,
                promotionPiece: Piece(type, color),
                capturedPiece: target,
              ));
            }
          } else {
            moves.add(Move(
              fromRow: row,
              fromCol: col,
              toRow: newRow,
              toCol: captureCol,
              capturedPiece: target,
            ));
          }
        }
        
        // En passant
        if (enPassantRow == newRow && enPassantCol == captureCol) {
          moves.add(Move(
            fromRow: row,
            fromCol: col,
            toRow: newRow,
            toCol: captureCol,
            isEnPassant: true,
            capturedPiece: board[row][captureCol],
          ));
        }
      }
    }
    
    return moves;
  }

  List<Move> _getKnightMoves(int row, int col, PieceColor color) {
    List<Move> moves = [];
    final offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1],
    ];
    
    for (final offset in offsets) {
      final newRow = row + offset[0];
      final newCol = col + offset[1];
      if (_isValidSquare(newRow, newCol)) {
        final target = board[newRow][newCol];
        if (target == null || target.color != color) {
          moves.add(Move(
            fromRow: row,
            fromCol: col,
            toRow: newRow,
            toCol: newCol,
            capturedPiece: target,
          ));
        }
      }
    }
    
    return moves;
  }

  List<Move> _getBishopMoves(int row, int col, PieceColor color) {
    return _getSlidingMoves(row, col, color, [
      [-1, -1], [-1, 1], [1, -1], [1, 1],
    ]);
  }

  List<Move> _getRookMoves(int row, int col, PieceColor color) {
    return _getSlidingMoves(row, col, color, [
      [-1, 0], [1, 0], [0, -1], [0, 1],
    ]);
  }

  List<Move> _getQueenMoves(int row, int col, PieceColor color) {
    return _getSlidingMoves(row, col, color, [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ]);
  }

  List<Move> _getSlidingMoves(int row, int col, PieceColor color, List<List<int>> directions) {
    List<Move> moves = [];
    
    for (final dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];
      
      while (_isValidSquare(newRow, newCol)) {
        final target = board[newRow][newCol];
        if (target == null) {
          moves.add(Move(fromRow: row, fromCol: col, toRow: newRow, toCol: newCol));
        } else {
          if (target.color != color) {
            moves.add(Move(
              fromRow: row,
              fromCol: col,
              toRow: newRow,
              toCol: newCol,
              capturedPiece: target,
            ));
          }
          break;
        }
        newRow += dir[0];
        newCol += dir[1];
      }
    }
    
    return moves;
  }

  List<Move> _getKingMoves(int row, int col, PieceColor color) {
    List<Move> moves = [];
    
    // Normal king moves
    for (int dRow = -1; dRow <= 1; dRow++) {
      for (int dCol = -1; dCol <= 1; dCol++) {
        if (dRow == 0 && dCol == 0) continue;
        final newRow = row + dRow;
        final newCol = col + dCol;
        if (_isValidSquare(newRow, newCol)) {
          final target = board[newRow][newCol];
          if (target == null || target.color != color) {
            moves.add(Move(
              fromRow: row,
              fromCol: col,
              toRow: newRow,
              toCol: newCol,
              capturedPiece: target,
            ));
          }
        }
      }
    }
    
    // Castling
    if (color == PieceColor.white && row == 7 && col == 4) {
      // Kingside
      if (whiteKingsideCastle &&
          board[7][5] == null &&
          board[7][6] == null &&
          !_isSquareAttacked(7, 4, PieceColor.black) &&
          !_isSquareAttacked(7, 5, PieceColor.black) &&
          !_isSquareAttacked(7, 6, PieceColor.black)) {
        moves.add(Move(fromRow: 7, fromCol: 4, toRow: 7, toCol: 6, isCastling: true));
      }
      // Queenside
      if (whiteQueensideCastle &&
          board[7][3] == null &&
          board[7][2] == null &&
          board[7][1] == null &&
          !_isSquareAttacked(7, 4, PieceColor.black) &&
          !_isSquareAttacked(7, 3, PieceColor.black) &&
          !_isSquareAttacked(7, 2, PieceColor.black)) {
        moves.add(Move(fromRow: 7, fromCol: 4, toRow: 7, toCol: 2, isCastling: true));
      }
    } else if (color == PieceColor.black && row == 0 && col == 4) {
      // Kingside
      if (blackKingsideCastle &&
          board[0][5] == null &&
          board[0][6] == null &&
          !_isSquareAttacked(0, 4, PieceColor.white) &&
          !_isSquareAttacked(0, 5, PieceColor.white) &&
          !_isSquareAttacked(0, 6, PieceColor.white)) {
        moves.add(Move(fromRow: 0, fromCol: 4, toRow: 0, toCol: 6, isCastling: true));
      }
      // Queenside
      if (blackQueensideCastle &&
          board[0][3] == null &&
          board[0][2] == null &&
          board[0][1] == null &&
          !_isSquareAttacked(0, 4, PieceColor.white) &&
          !_isSquareAttacked(0, 3, PieceColor.white) &&
          !_isSquareAttacked(0, 2, PieceColor.white)) {
        moves.add(Move(fromRow: 0, fromCol: 4, toRow: 0, toCol: 2, isCastling: true));
      }
    }
    
    return moves;
  }

  bool _isValidSquare(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool _leavesKingInCheck(Move move) {
    // Make the move temporarily
    final piece = board[move.fromRow][move.fromCol];
    final captured = board[move.toRow][move.toCol];
    
    board[move.toRow][move.toCol] = piece;
    board[move.fromRow][move.fromCol] = null;
    
    // Handle en passant capture
    Piece? enPassantCaptured;
    if (move.isEnPassant) {
      enPassantCaptured = board[move.fromRow][move.toCol];
      board[move.fromRow][move.toCol] = null;
    }
    
    // Check if king is in check
    final kingPos = _findKing(currentTurn);
    final inCheck = _isSquareAttacked(kingPos[0], kingPos[1], _oppositeColor(currentTurn));
    
    // Undo the move
    board[move.fromRow][move.fromCol] = piece;
    board[move.toRow][move.toCol] = captured;
    if (move.isEnPassant) {
      board[move.fromRow][move.toCol] = enPassantCaptured;
    }
    
    return inCheck;
  }

  List<int> _findKing(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.type == PieceType.king && piece.color == color) {
          return [row, col];
        }
      }
    }
    throw Exception('King not found!');
  }

  bool _isSquareAttacked(int row, int col, PieceColor attackerColor) {
    // Check pawn attacks
    final pawnDir = attackerColor == PieceColor.white ? 1 : -1;
    for (final colOffset in [-1, 1]) {
      final attackRow = row + pawnDir;
      final attackCol = col + colOffset;
      if (_isValidSquare(attackRow, attackCol)) {
        final piece = board[attackRow][attackCol];
        if (piece != null &&
            piece.type == PieceType.pawn &&
            piece.color == attackerColor) {
          return true;
        }
      }
    }
    
    // Check knight attacks
    final knightOffsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1],
    ];
    for (final offset in knightOffsets) {
      final attackRow = row + offset[0];
      final attackCol = col + offset[1];
      if (_isValidSquare(attackRow, attackCol)) {
        final piece = board[attackRow][attackCol];
        if (piece != null &&
            piece.type == PieceType.knight &&
            piece.color == attackerColor) {
          return true;
        }
      }
    }
    
    // Check sliding piece attacks (bishop, rook, queen)
    final directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ];
    
    for (final dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];
      
      while (_isValidSquare(newRow, newCol)) {
        final piece = board[newRow][newCol];
        if (piece != null) {
          if (piece.color == attackerColor) {
            final isDiagonal = dir[0] != 0 && dir[1] != 0;
            final isStraight = dir[0] == 0 || dir[1] == 0;
            
            if (piece.type == PieceType.queen ||
                (isDiagonal && piece.type == PieceType.bishop) ||
                (isStraight && piece.type == PieceType.rook)) {
              return true;
            }
          }
          break;
        }
        newRow += dir[0];
        newCol += dir[1];
      }
    }
    
    // Check king attacks
    for (int dRow = -1; dRow <= 1; dRow++) {
      for (int dCol = -1; dCol <= 1; dCol++) {
        if (dRow == 0 && dCol == 0) continue;
        final attackRow = row + dRow;
        final attackCol = col + dCol;
        if (_isValidSquare(attackRow, attackCol)) {
          final piece = board[attackRow][attackCol];
          if (piece != null &&
              piece.type == PieceType.king &&
              piece.color == attackerColor) {
            return true;
          }
        }
      }
    }
    
    return false;
  }

  PieceColor _oppositeColor(PieceColor color) {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  // Make a move
  bool makeMove(Move move) {
    final piece = board[move.fromRow][move.fromCol];
    if (piece == null) return false;
    
    // Execute the move
    board[move.toRow][move.toCol] = move.promotionPiece ?? piece;
    board[move.fromRow][move.fromCol] = null;
    
    // Handle en passant capture
    if (move.isEnPassant) {
      board[move.fromRow][move.toCol] = null;
    }
    
    // Handle castling
    if (move.isCastling) {
      if (move.toCol == 6) {
        // Kingside
        final rookRow = move.fromRow;
        board[rookRow][5] = board[rookRow][7];
        board[rookRow][7] = null;
      } else if (move.toCol == 2) {
        // Queenside
        final rookRow = move.fromRow;
        board[rookRow][3] = board[rookRow][0];
        board[rookRow][0] = null;
      }
    }
    
    // Update en passant target
    enPassantRow = null;
    enPassantCol = null;
    if (piece.type == PieceType.pawn && (move.toRow - move.fromRow).abs() == 2) {
      enPassantRow = (move.fromRow + move.toRow) ~/ 2;
      enPassantCol = move.fromCol;
    }
    
    // Update castling rights
    if (piece.type == PieceType.king) {
      if (piece.color == PieceColor.white) {
        whiteKingsideCastle = false;
        whiteQueensideCastle = false;
      } else {
        blackKingsideCastle = false;
        blackQueensideCastle = false;
      }
    } else if (piece.type == PieceType.rook) {
      if (piece.color == PieceColor.white) {
        if (move.fromRow == 7 && move.fromCol == 0) whiteQueensideCastle = false;
        if (move.fromRow == 7 && move.fromCol == 7) whiteKingsideCastle = false;
      } else {
        if (move.fromRow == 0 && move.fromCol == 0) blackQueensideCastle = false;
        if (move.fromRow == 0 && move.fromCol == 7) blackKingsideCastle = false;
      }
    }
    
    // Update move counters
    if (piece.type == PieceType.pawn || move.capturedPiece != null) {
      halfMoveClock = 0;
    } else {
      halfMoveClock++;
    }
    
    if (currentTurn == PieceColor.black) {
      fullMoveNumber++;
    }
    
    // Add to history
    moveHistory.add(move);
    positionHistory.add(_getBoardHash());
    
    // Switch turn
    currentTurn = _oppositeColor(currentTurn);
    
    return true;
  }

  // Undo last move
  bool undoMove() {
    if (moveHistory.isEmpty) return false;
    
    final move = moveHistory.removeLast();
    positionHistory.removeLast();
    
    // Switch turn back
    currentTurn = _oppositeColor(currentTurn);
    
    // Restore piece
    final piece = board[move.toRow][move.toCol];
    board[move.fromRow][move.fromCol] = move.promotionPiece != null
        ? Piece(PieceType.pawn, currentTurn)
        : piece;
    board[move.toRow][move.toCol] = move.capturedPiece;
    
    // Restore en passant capture
    if (move.isEnPassant) {
      board[move.fromRow][move.toCol] = move.capturedPiece;
      board[move.toRow][move.toCol] = null;
    }
    
    // Restore castling
    if (move.isCastling) {
      if (move.toCol == 6) {
        // Kingside
        final rookRow = move.fromRow;
        board[rookRow][7] = board[rookRow][5];
        board[rookRow][5] = null;
      } else if (move.toCol == 2) {
        // Queenside
        final rookRow = move.fromRow;
        board[rookRow][0] = board[rookRow][3];
        board[rookRow][3] = null;
      }
    }
    
    // Note: Castling rights and en passant are not perfectly restored
    // For a production game, you'd need to store these in the move history
    
    return true;
  }

  // Get game status
  GameStatus getGameStatus() {
    final legalMoves = getLegalMoves();
    final kingPos = _findKing(currentTurn);
    final inCheck = _isSquareAttacked(kingPos[0], kingPos[1], _oppositeColor(currentTurn));
    
    if (legalMoves.isEmpty) {
      return inCheck ? GameStatus.checkmate : GameStatus.stalemate;
    }
    
    // Check for draw conditions
    if (halfMoveClock >= 100) return GameStatus.draw; // 50-move rule
    if (_isThreefoldRepetition()) return GameStatus.draw;
    if (_isInsufficientMaterial()) return GameStatus.draw;
    
    return inCheck ? GameStatus.check : GameStatus.playing;
  }

  bool _isThreefoldRepetition() {
    if (positionHistory.length < 3) return false;
    final currentPos = positionHistory.last;
    int count = 0;
    for (final pos in positionHistory) {
      if (pos == currentPos) count++;
      if (count >= 3) return true;
    }
    return false;
  }

  bool _isInsufficientMaterial() {
    List<Piece> pieces = [];
    for (final row in board) {
      for (final piece in row) {
        if (piece != null && piece.type != PieceType.king) {
          pieces.add(piece);
        }
      }
    }
    
    // King vs King
    if (pieces.isEmpty) return true;
    
    // King + minor piece vs King
    if (pieces.length == 1) {
      final piece = pieces[0];
      return piece.type == PieceType.knight || piece.type == PieceType.bishop;
    }
    
    // King + Bishop vs King + Bishop (same color squares)
    if (pieces.length == 2) {
      if (pieces.every((p) => p.type == PieceType.bishop)) {
        // Check if bishops are on same color squares
        // This is a simplified check
        return true;
      }
    }
    
    return false;
  }

  String _getBoardHash() {
    StringBuffer sb = StringBuffer();
    for (final row in board) {
      for (final piece in row) {
        if (piece == null) {
          sb.write('.');
        } else {
          sb.write(piece.symbol);
        }
      }
    }
    sb.write(currentTurn == PieceColor.white ? 'w' : 'b');
    return sb.toString();
  }

  // Create a copy of the engine
  ChessEngine copy() {
    final copy = ChessEngine();
    copy.board = List.generate(8, (i) => List.from(board[i]));
    copy.currentTurn = currentTurn;
    copy.whiteKingsideCastle = whiteKingsideCastle;
    copy.whiteQueensideCastle = whiteQueensideCastle;
    copy.blackKingsideCastle = blackKingsideCastle;
    copy.blackQueensideCastle = blackQueensideCastle;
    copy.enPassantRow = enPassantRow;
    copy.enPassantCol = enPassantCol;
    copy.halfMoveClock = halfMoveClock;
    copy.fullMoveNumber = fullMoveNumber;
    copy.moveHistory = List.from(moveHistory);
    copy.positionHistory = List.from(positionHistory);
    return copy;
  }
}
