import 'package:flutter/foundation.dart';
import '../engine/chess_engine.dart';
import '../engine/move.dart';
import '../engine/piece.dart';
import '../models/game_state.dart';
import '../ai/chess_ai.dart';
import '../config/game_config.dart';

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

    // Undo AI move
    if (!_state.isPlayerTurn && _state.engine.moveHistory.isNotEmpty) {
      _state.engine.undoMove();
    }

    // Undo player move
    if (_state.engine.moveHistory.isNotEmpty) {
      _state.engine.undoMove();
    }

    _state = _state.copyWith(
      clearSelection: true,
      clearLastMove: true,
      legalMovesForSelected: [],
      status: _state.engine.getGameStatus(),
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

  void startAIMove() {
    if (!_state.isPlayerTurn && !_state.isAIThinking && !_state.isGameOver) {
      _makeAIMove();
    }
  }
}
