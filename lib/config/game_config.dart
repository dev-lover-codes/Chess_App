// Stage configuration
class StageConfig {
  final int stage;
  final String name;
  final String description;
  final int aiLevel;
  final int? undoLimit;
  final Duration? timeLimit;
  final bool hintsAllowed;

  const StageConfig({
    required this.stage,
    required this.name,
    required this.description,
    required this.aiLevel,
    this.undoLimit,
    this.timeLimit,
    this.hintsAllowed = true,
  });
}

// All 15 stages configuration
class GameConfig {
  static const List<StageConfig> stages = [
    // Beginner stages (1-3)
    StageConfig(
      stage: 1,
      name: 'Beginner 1',
      description: 'AI makes completely random moves. Perfect for learning!',
      aiLevel: 1,
      undoLimit: null, // Unlimited
      hintsAllowed: true,
    ),
    StageConfig(
      stage: 2,
      name: 'Beginner 2',
      description: 'AI occasionally captures pieces but still plays randomly.',
      aiLevel: 2,
      undoLimit: 10,
      hintsAllowed: true,
    ),
    StageConfig(
      stage: 3,
      name: 'Beginner 3',
      description: 'AI prefers captures and avoids some blunders.',
      aiLevel: 3,
      undoLimit: 5,
      hintsAllowed: true,
    ),
    
    // Easy stages (4-6)
    StageConfig(
      stage: 4,
      name: 'Easy 1',
      description: 'AI understands piece values and tries to win material.',
      aiLevel: 4,
      undoLimit: 5,
      hintsAllowed: true,
    ),
    StageConfig(
      stage: 5,
      name: 'Easy 2',
      description: 'AI actively seeks favorable trades.',
      aiLevel: 5,
      undoLimit: 3,
      hintsAllowed: true,
    ),
    StageConfig(
      stage: 6,
      name: 'Easy 3',
      description: 'AI consistently makes material-gaining moves.',
      aiLevel: 6,
      undoLimit: 3,
      hintsAllowed: true,
    ),
    
    // Intermediate stages (7-9)
    StageConfig(
      stage: 7,
      name: 'Intermediate 1',
      description: 'AI thinks 2 moves ahead and recognizes basic tactics.',
      aiLevel: 7,
      undoLimit: 2,
      hintsAllowed: true,
    ),
    StageConfig(
      stage: 8,
      name: 'Intermediate 2',
      description: 'AI uses positional evaluation and plans ahead.',
      aiLevel: 8,
      undoLimit: 2,
      hintsAllowed: true,
    ),
    StageConfig(
      stage: 9,
      name: 'Intermediate 3',
      description: 'AI thinks 3 moves ahead with solid tactical play.',
      aiLevel: 9,
      undoLimit: 1,
      hintsAllowed: true,
    ),
    
    // Advanced stages (10-12)
    StageConfig(
      stage: 10,
      name: 'Advanced 1',
      description: 'AI uses alpha-beta pruning and strong positional play.',
      aiLevel: 10,
      undoLimit: 1,
      hintsAllowed: false,
    ),
    StageConfig(
      stage: 11,
      name: 'Advanced 2',
      description: 'AI thinks 4 moves ahead with excellent tactics.',
      aiLevel: 11,
      undoLimit: 0,
      hintsAllowed: false,
    ),
    StageConfig(
      stage: 12,
      name: 'Advanced 3',
      description: 'AI plays near-perfect tactical chess.',
      aiLevel: 12,
      undoLimit: 0,
      hintsAllowed: false,
    ),
    
    // Expert/Boss stages (13-15)
    StageConfig(
      stage: 13,
      name: 'Expert 1',
      description: 'AI uses advanced algorithms and deep calculation.',
      aiLevel: 13,
      undoLimit: 0,
      hintsAllowed: false,
    ),
    StageConfig(
      stage: 14,
      name: 'Expert 2',
      description: 'AI with transposition tables and quiescence search.',
      aiLevel: 14,
      undoLimit: 0,
      hintsAllowed: false,
    ),
    StageConfig(
      stage: 15,
      name: 'Master (Boss)',
      description: 'The ultimate challenge! AI plays at master level.',
      aiLevel: 15,
      undoLimit: 0,
      hintsAllowed: false,
    ),
  ];

  static StageConfig getStage(int stage) {
    return stages[stage - 1];
  }

  // Animation durations
  static const Duration pieceMoveAnimation = Duration(milliseconds: 300);
  static const Duration captureAnimation = Duration(milliseconds: 200);
  static const Duration checkAnimation = Duration(milliseconds: 500);

  // Board colors
  static const int lightSquareColor = 0xFFF0D9B5;
  static const int darkSquareColor = 0xFFB58863;
  static const int selectedSquareColor = 0xFF829769;
  static const int legalMoveColor = 0x80829769;
  static const int lastMoveColor = 0x80CDD26A;
  static const int checkColor = 0x80FF6B6B;

  // Storage keys
  static const String storageKeyProgress = 'chess_progress';
  static const String storageKeySettings = 'chess_settings';
}
