import 'dart:math';
import '../engine/chess_engine.dart';
import '../engine/move.dart';
import 'evaluator.dart';

// Abstract AI interface
abstract class ChessAI {
  Future<Move?> getBestMove(ChessEngine engine);
  String get name;
  int get difficulty; // 1-15
}

// Factory to create AI for each stage
class AIFactory {
  static ChessAI createAI(int stage) {
    if (stage < 1 || stage > 15) {
      throw ArgumentError('Stage must be between 1 and 15');
    }

    if (stage <= 3) {
      return RandomAI(stage);
    } else if (stage <= 6) {
      return MaterialAI(stage);
    } else if (stage <= 9) {
      return MinimaxAI(stage);
    } else if (stage <= 12) {
      return AlphaBetaAI(stage);
    } else {
      return AdvancedAI(stage);
    }
  }
}

// Stages 1-3: Random moves with blunders
class RandomAI extends ChessAI {
  final int stage;
  final Random _random = Random();

  RandomAI(this.stage);

  @override
  String get name => 'Beginner ${stage}';

  @override
  int get difficulty => stage;

  @override
  Future<Move?> getBestMove(ChessEngine engine) async {
    final moves = engine.getLegalMoves();
    if (moves.isEmpty) return null;

    // Stage 1: Pure random
    if (stage == 1) {
      return moves[_random.nextInt(moves.length)];
    }

    // Stage 2: Slightly prefer captures
    if (stage == 2) {
      final captures = moves.where((m) => m.capturedPiece != null).toList();
      if (captures.isNotEmpty && _random.nextDouble() < 0.3) {
        return captures[_random.nextInt(captures.length)];
      }
      return moves[_random.nextInt(moves.length)];
    }

    // Stage 3: Avoid obvious blunders sometimes
    if (stage == 3) {
      final captures = moves.where((m) => m.capturedPiece != null).toList();
      if (captures.isNotEmpty && _random.nextDouble() < 0.5) {
        return captures[_random.nextInt(captures.length)];
      }
      return moves[_random.nextInt(moves.length)];
    }

    return moves[_random.nextInt(moves.length)];
  }
}

// Stages 4-6: Material-based evaluation
class MaterialAI extends ChessAI {
  final int stage;
  final Random _random = Random();

  MaterialAI(this.stage);

  @override
  String get name => 'Easy ${stage - 3}';

  @override
  int get difficulty => stage;

  @override
  Future<Move?> getBestMove(ChessEngine engine) async {
    final moves = engine.getLegalMoves();
    if (moves.isEmpty) return null;

    Move? bestMove;
    int bestScore = -999999;

    for (final move in moves) {
      final testEngine = engine.copy();
      testEngine.makeMove(move);

      int score = -Evaluator.evaluateMaterial(testEngine);

      // Add randomness based on stage
      final randomFactor = (7 - stage) * 50;
      score += _random.nextInt(randomFactor) - randomFactor ~/ 2;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }
}

// Stages 7-9: Minimax algorithm
class MinimaxAI extends ChessAI {
  final int stage;
  final Random _random = Random();

  MinimaxAI(this.stage);

  @override
  String get name => 'Intermediate ${stage - 6}';

  @override
  int get difficulty => stage;

  int get _depth {
    if (stage == 7) return 2;
    if (stage == 8) return 2;
    return 3;
  }

  @override
  Future<Move?> getBestMove(ChessEngine engine) async {
    final moves = engine.getLegalMoves();
    if (moves.isEmpty) return null;

    Move? bestMove;
    int bestScore = -999999;

    for (final move in moves) {
      final testEngine = engine.copy();
      testEngine.makeMove(move);

      final score = -_minimax(testEngine, _depth - 1, false);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      } else if (score == bestScore && _random.nextBool()) {
        bestMove = move;
      }
    }

    return bestMove;
  }

  int _minimax(ChessEngine engine, int depth, bool maximizing) {
    if (depth == 0) {
      return Evaluator.evaluate(engine, usePositional: stage >= 8);
    }

    final moves = engine.getLegalMoves();
    if (moves.isEmpty) {
      final status = engine.getGameStatus();
      if (status == GameStatus.checkmate) {
        return maximizing ? -999999 : 999999;
      }
      return 0; // Stalemate
    }

    if (maximizing) {
      int maxScore = -999999;
      for (final move in moves) {
        final testEngine = engine.copy();
        testEngine.makeMove(move);
        final score = _minimax(testEngine, depth - 1, false);
        maxScore = max(maxScore, score);
      }
      return maxScore;
    } else {
      int minScore = 999999;
      for (final move in moves) {
        final testEngine = engine.copy();
        testEngine.makeMove(move);
        final score = _minimax(testEngine, depth - 1, true);
        minScore = min(minScore, score);
      }
      return minScore;
    }
  }
}

// Stages 10-12: Alpha-beta pruning
class AlphaBetaAI extends ChessAI {
  final int stage;
  final Random _random = Random();

  AlphaBetaAI(this.stage);

  @override
  String get name => 'Advanced ${stage - 9}';

  @override
  int get difficulty => stage;

  int get _depth {
    if (stage == 10) return 3;
    if (stage == 11) return 4;
    return 4;
  }

  @override
  Future<Move?> getBestMove(ChessEngine engine) async {
    final moves = engine.getLegalMoves();
    if (moves.isEmpty) return null;

    // Order moves: captures first
    moves.sort((a, b) {
      if (a.capturedPiece != null && b.capturedPiece == null) return -1;
      if (a.capturedPiece == null && b.capturedPiece != null) return 1;
      if (a.capturedPiece != null && b.capturedPiece != null) {
        return b.capturedPiece!.value.compareTo(a.capturedPiece!.value);
      }
      return 0;
    });

    Move? bestMove;
    int bestScore = -999999;

    for (final move in moves) {
      final testEngine = engine.copy();
      testEngine.makeMove(move);

      final score = -_alphaBeta(testEngine, _depth - 1, -999999, 999999, false);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      } else if (score == bestScore && _random.nextBool()) {
        bestMove = move;
      }
    }

    return bestMove;
  }

  int _alphaBeta(ChessEngine engine, int depth, int alpha, int beta, bool maximizing) {
    if (depth == 0) {
      return Evaluator.evaluate(engine, usePositional: true);
    }

    final moves = engine.getLegalMoves();
    if (moves.isEmpty) {
      final status = engine.getGameStatus();
      if (status == GameStatus.checkmate) {
        return maximizing ? -999999 : 999999;
      }
      return 0;
    }

    if (maximizing) {
      int maxScore = -999999;
      for (final move in moves) {
        final testEngine = engine.copy();
        testEngine.makeMove(move);
        final score = _alphaBeta(testEngine, depth - 1, alpha, beta, false);
        maxScore = max(maxScore, score);
        alpha = max(alpha, score);
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxScore;
    } else {
      int minScore = 999999;
      for (final move in moves) {
        final testEngine = engine.copy();
        testEngine.makeMove(move);
        final score = _alphaBeta(testEngine, depth - 1, alpha, beta, true);
        minScore = min(minScore, score);
        beta = min(beta, score);
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minScore;
    }
  }
}

// Stages 13-15: Advanced AI with deeper search
class AdvancedAI extends ChessAI {
  final int stage;
  final Random _random = Random();
  final Map<String, int> _transpositionTable = {};

  AdvancedAI(this.stage);

  @override
  String get name {
    if (stage == 13) return 'Expert 1';
    if (stage == 14) return 'Expert 2';
    return 'Master (Boss)';
  }

  @override
  int get difficulty => stage;

  int get _depth {
    if (stage == 13) return 5;
    if (stage == 14) return 5;
    return 6;
  }

  @override
  Future<Move?> getBestMove(ChessEngine engine) async {
    _transpositionTable.clear();
    
    final moves = engine.getLegalMoves();
    if (moves.isEmpty) return null;

    // Advanced move ordering
    moves.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      // Prioritize captures (MVV-LVA)
      if (a.capturedPiece != null) {
        scoreA += a.capturedPiece!.value * 10;
        scoreA -= engine.board[a.fromRow][a.fromCol]!.value;
      }
      if (b.capturedPiece != null) {
        scoreB += b.capturedPiece!.value * 10;
        scoreB -= engine.board[b.fromRow][b.fromCol]!.value;
      }

      // Prioritize promotions
      if (a.promotionPiece != null) scoreA += 8000;
      if (b.promotionPiece != null) scoreB += 8000;

      // Prioritize center control
      final aCenterDist = (3.5 - a.toRow).abs() + (3.5 - a.toCol).abs();
      final bCenterDist = (3.5 - b.toRow).abs() + (3.5 - b.toCol).abs();
      scoreA -= aCenterDist.toInt() * 10;
      scoreB -= bCenterDist.toInt() * 10;

      return scoreB.compareTo(scoreA);
    });

    Move? bestMove;
    int bestScore = -999999;

    for (final move in moves) {
      final testEngine = engine.copy();
      testEngine.makeMove(move);

      final score = -_alphaBetaWithTransposition(
        testEngine,
        _depth - 1,
        -999999,
        999999,
        false,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      } else if (score == bestScore && _random.nextBool()) {
        bestMove = move;
      }
    }

    return bestMove;
  }

  int _alphaBetaWithTransposition(
    ChessEngine engine,
    int depth,
    int alpha,
    int beta,
    bool maximizing,
  ) {
    // Check transposition table
    final posHash = _getPositionHash(engine);
    if (_transpositionTable.containsKey(posHash)) {
      return _transpositionTable[posHash]!;
    }

    if (depth == 0) {
      final score = _quiescenceSearch(engine, alpha, beta, maximizing);
      _transpositionTable[posHash] = score;
      return score;
    }

    final moves = engine.getLegalMoves();
    if (moves.isEmpty) {
      final status = engine.getGameStatus();
      if (status == GameStatus.checkmate) {
        return maximizing ? -999999 + depth : 999999 - depth;
      }
      return 0;
    }

    if (maximizing) {
      int maxScore = -999999;
      for (final move in moves) {
        final testEngine = engine.copy();
        testEngine.makeMove(move);
        final score = _alphaBetaWithTransposition(
          testEngine,
          depth - 1,
          alpha,
          beta,
          false,
        );
        maxScore = max(maxScore, score);
        alpha = max(alpha, score);
        if (beta <= alpha) break;
      }
      _transpositionTable[posHash] = maxScore;
      return maxScore;
    } else {
      int minScore = 999999;
      for (final move in moves) {
        final testEngine = engine.copy();
        testEngine.makeMove(move);
        final score = _alphaBetaWithTransposition(
          testEngine,
          depth - 1,
          alpha,
          beta,
          true,
        );
        minScore = min(minScore, score);
        beta = min(beta, score);
        if (beta <= alpha) break;
      }
      _transpositionTable[posHash] = minScore;
      return minScore;
    }
  }

  // Quiescence search to avoid horizon effect
  int _quiescenceSearch(ChessEngine engine, int alpha, int beta, bool maximizing) {
    final standPat = Evaluator.evaluate(engine, usePositional: true);

    if (!maximizing) {
      if (standPat <= alpha) return alpha;
      if (standPat < beta) beta = standPat;
    } else {
      if (standPat >= beta) return beta;
      if (standPat > alpha) alpha = standPat;
    }

    final moves = engine.getLegalMoves();
    final captures = moves.where((m) => m.capturedPiece != null).toList();

    if (captures.isEmpty) return standPat;

    for (final move in captures) {
      final testEngine = engine.copy();
      testEngine.makeMove(move);
      final score = _quiescenceSearch(testEngine, alpha, beta, !maximizing);

      if (maximizing) {
        if (score >= beta) return beta;
        if (score > alpha) alpha = score;
      } else {
        if (score <= alpha) return alpha;
        if (score < beta) beta = score;
      }
    }

    return maximizing ? alpha : beta;
  }

  String _getPositionHash(ChessEngine engine) {
    StringBuffer sb = StringBuffer();
    for (final row in engine.board) {
      for (final piece in row) {
        if (piece == null) {
          sb.write('.');
        } else {
          sb.write(piece.symbol);
        }
      }
    }
    return sb.toString();
  }
}
