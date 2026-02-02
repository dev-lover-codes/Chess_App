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
  final Move? hintMove; // For showing hint visually on board
  final Move? highlightedMove; // For showing clicked history move on board
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
    this.hintMove,
    this.highlightedMove,
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
    Move? hintMove,
    Move? highlightedMove,
    GameStatus? status,
    PieceColor? playerColor,
    int? currentStage,
    bool? isAIThinking,
    bool clearSelection = false,
    bool clearLastMove = false,
    bool clearHint = false,
    bool clearHighlight = false,
  }) {
    return GameState(
      engine: engine ?? this.engine,
      selectedRow: clearSelection ? null : (selectedRow ?? this.selectedRow),
      selectedCol: clearSelection ? null : (selectedCol ?? this.selectedCol),
      legalMovesForSelected: legalMovesForSelected ?? this.legalMovesForSelected,
      lastMove: clearLastMove ? null : (lastMove ?? this.lastMove),
      hintMove: clearHint ? null : (hintMove ?? this.hintMove),
      highlightedMove: clearHighlight ? null : (highlightedMove ?? this.highlightedMove),
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
