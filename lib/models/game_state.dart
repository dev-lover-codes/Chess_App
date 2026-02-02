import '../engine/chess_engine.dart';
import '../engine/move.dart';
import '../engine/piece.dart';

// Game state model
class GameState {
  final ChessEngine engine;
  final int? selectedRow;
  final int? selectedCol;
  final List<Move> legalMovesForSelected;
  final Move? lastMove;
  final GameStatus status;
  final PieceColor playerColor;
  final int currentStage;
  final bool isAIThinking;

  GameState({
    required this.engine,
    this.selectedRow,
    this.selectedCol,
    this.legalMovesForSelected = const [],
    this.lastMove,
    required this.status,
    this.playerColor = PieceColor.white,
    required this.currentStage,
    this.isAIThinking = false,
  });

  GameState copyWith({
    ChessEngine? engine,
    int? selectedRow,
    int? selectedCol,
    List<Move>? legalMovesForSelected,
    Move? lastMove,
    GameStatus? status,
    PieceColor? playerColor,
    int? currentStage,
    bool? isAIThinking,
    bool clearSelection = false,
    bool clearLastMove = false,
  }) {
    return GameState(
      engine: engine ?? this.engine,
      selectedRow: clearSelection ? null : (selectedRow ?? this.selectedRow),
      selectedCol: clearSelection ? null : (selectedCol ?? this.selectedCol),
      legalMovesForSelected: legalMovesForSelected ?? this.legalMovesForSelected,
      lastMove: clearLastMove ? null : (lastMove ?? this.lastMove),
      status: status ?? this.status,
      playerColor: playerColor ?? this.playerColor,
      currentStage: currentStage ?? this.currentStage,
      isAIThinking: isAIThinking ?? this.isAIThinking,
    );
  }

  bool get isPlayerTurn => engine.currentTurn == playerColor;
  
  bool get canUndo => engine.moveHistory.isNotEmpty && !isAIThinking;
  
  bool get isGameOver =>
      status == GameStatus.checkmate ||
      status == GameStatus.stalemate ||
      status == GameStatus.draw;
}
