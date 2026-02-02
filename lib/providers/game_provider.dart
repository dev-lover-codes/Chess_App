import 'package:flutter/foundation.dart';
import '../engine/chess_engine.dart';
import '../engine/move.dart';
import '../engine/piece.dart';
import '../models/game_state.dart';
import '../ai/chess_ai.dart';

class GameProvider extends ChangeNotifier {
  GameState _state;
  ChessAI? _ai;
  final Function(String)? onGameEvent;

  GameProvider({
    required int stage,
    this.onGameEvent,
  }) : _state = GameState(
          engine: ChessEngine(),
          status: GameStatus.playing,
          currentStage: stage,
        ) {
    _ai = AIFactory.createAI(stage);
  }

  GameState get state => _state;

  void selectSquare(int row, int col) {
    if (_state.isAIThinking || _state.isGameOver) return;

    final piece = _state.engine.board[row][col];

    // If clicking on own piece, select it
    if (piece != null && piece.color == _state.playerColor) {
      final legalMoves = _state.engine.getLegalMovesForPiece(row, col);
      _state = _state.copyWith(
        selectedRow: row,
        selectedCol: col,
        legalMovesForSelected: legalMoves,
      );
      notifyListeners();
      return;
    }

    // If a piece is selected, try to move it
    if (_state.selectedRow != null && _state.selectedCol != null) {
      final move = _state.legalMovesForSelected.firstWhere(
        (m) => m.toRow == row && m.toCol == col,
        orElse: () => Move(fromRow: -1, fromCol: -1, toRow: -1, toCol: -1),
      );

      if (move.fromRow != -1) {
        // Check if pawn promotion
        final movingPiece = _state.engine.board[_state.selectedRow!][_state.selectedCol!];
        if (movingPiece?.type == PieceType.pawn &&
            (row == 0 || row == 7)) {
          // Trigger promotion dialog (handled by UI)
          onGameEvent?.call('promotion_needed:$row:$col');
          return;
        }

        _makePlayerMove(move);
      } else {
        // Deselect
        _state = _state.copyWith(clearSelection: true, legalMovesForSelected: []);
        notifyListeners();
      }
    }
  }

  void makePromotionMove(int row, int col, PieceType promotionType) {
    if (_state.selectedRow == null || _state.selectedCol == null) return;

    final move = Move(
      fromRow: _state.selectedRow!,
      fromCol: _state.selectedCol!,
      toRow: row,
      toCol: col,
      promotionPiece: Piece(promotionType, _state.playerColor),
      capturedPiece: _state.engine.board[row][col],
    );

    _makePlayerMove(move);
  }

  void _makePlayerMove(Move move) {
    _state.engine.makeMove(move);
    
    final status = _state.engine.getGameStatus();
    _state = _state.copyWith(
      clearSelection: true,
      legalMovesForSelected: [],
      lastMove: move,
      status: status,
    );

    if (move.capturedPiece != null) {
      onGameEvent?.call('capture');
    } else {
      onGameEvent?.call('move');
    }

    if (status == GameStatus.check) {
      onGameEvent?.call('check');
    } else if (status == GameStatus.checkmate) {
      onGameEvent?.call('checkmate');
      // Player won!
      onGameEvent?.call('player_won');
    } else if (status == GameStatus.stalemate || status == GameStatus.draw) {
      onGameEvent?.call('draw');
    }

    notifyListeners();

    // Trigger AI move if game continues
    if (!_state.isGameOver && !_state.isPlayerTurn) {
      _makeAIMove();
    }
  }

  Future<void> _makeAIMove() async {
    _state = _state.copyWith(isAIThinking: true);
    notifyListeners();

    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    final aiMove = await _ai?.getBestMove(_state.engine);

    if (aiMove != null) {
      _state.engine.makeMove(aiMove);
      
      final status = _state.engine.getGameStatus();
      _state = _state.copyWith(
        isAIThinking: false,
        lastMove: aiMove,
        status: status,
      );

      if (aiMove.capturedPiece != null) {
        onGameEvent?.call('capture');
      } else {
        onGameEvent?.call('move');
      }

      if (status == GameStatus.check) {
        onGameEvent?.call('check');
      } else if (status == GameStatus.checkmate) {
        onGameEvent?.call('checkmate');
        // AI won
        onGameEvent?.call('ai_won');
      } else if (status == GameStatus.stalemate || status == GameStatus.draw) {
        onGameEvent?.call('draw');
      }

      notifyListeners();
    } else {
      _state = _state.copyWith(isAIThinking: false);
      notifyListeners();
    }
  }

  void undoMove() {
    if (!_state.canUndo) return;

    final moveCount = _state.engine.moveHistory.length;
    
    // Try to undo 2 moves (your move + AI's move) for best UX
    if (moveCount >= 2) {
      // Undo AI's last move
      _state.engine.undoMove();
      // Undo your last move
      _state.engine.undoMove();
    } else if (moveCount == 1) {
      // Only one move exists, just undo it
      _state.engine.undoMove();
    } else {
      // No moves to undo
      return;
    }

    _state = _state.copyWith(
      clearSelection: true,
      clearLastMove: true,
      legalMovesForSelected: [],
      status: _state.engine.getGameStatus(),
      isAIThinking: false,
    );

    notifyListeners();
  }

  void resetGame() {
    _state = GameState(
      engine: ChessEngine(),
      status: GameStatus.playing,
      currentStage: _state.currentStage,
    );
    notifyListeners();
  }

  Future<Move?> getHint() async {
    if (_state.isAIThinking || _state.isGameOver) return null;
    return await _ai?.getBestMove(_state.engine);
  }

  // Show hint visually on the board
  void showHintOnBoard(Move hint) {
    _state = _state.copyWith(hintMove: hint, clearHighlight: true);
    notifyListeners();
  }

  // Clear hint from board
  void clearHint() {
    _state = _state.copyWith(clearHint: true);
    notifyListeners();
  }

  // Show a history move on the board (when user clicks it)
  void showHistoryMoveOnBoard(Move move) {
    _state = _state.copyWith(highlightedMove: move, clearHint: true);
    notifyListeners();
  }

  // Clear highlighted history move
  void clearHighlightedMove() {
    _state = _state.copyWith(clearHighlight: true);
    notifyListeners();
  }

  void startAIMove() {
    if (!_state.isPlayerTurn && !_state.isAIThinking && !_state.isGameOver) {
      _makeAIMove();
    }
  }
}
