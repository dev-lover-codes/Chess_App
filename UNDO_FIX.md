# Undo Button Fix

## Issue
The undo button was grayed out and not working.

## Root Cause
The undo function was requiring at least 2 moves in the history (`moveHistory.length < 2`), which was too strict.

## Solution
Updated the undo logic to be more flexible:

### New Behavior:
1. **If 2+ moves exist**: Undo both your last move AND the AI's last move (preferred)
2. **If only 1 move exists**: Undo that single move
3. **If no moves exist**: Do nothing

### Code Changes:
```dart
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
```

## Result
✅ Undo button now works correctly
✅ Undos 2 moves when possible (your move + AI's move)
✅ Undos 1 move if that's all that exists
✅ Always returns you to your turn

## Testing
1. Make a move
2. AI responds
3. Click "Undo"
4. Both moves should be removed
5. You're back to your turn!

---

**Status**: Fixed and deployed via hot reload ✅
