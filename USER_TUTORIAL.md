# Chess Master - User Tutorial

Welcome to **Chess Master**! This tutorial will guide you through all the features of the app and help you make the most of your chess learning experience.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Landing Screen](#landing-screen)
3. [Authentication](#authentication)
4. [Stage Selection](#stage-selection)
5. [Playing a Game](#playing-a-game)
6. [Game Controls & Features](#game-controls--features)
7. [Understanding Stages](#understanding-stages)
8. [Settings & Preferences](#settings--preferences)
9. [Progress Tracking](#progress-tracking)
10. [Tips for Success](#tips-for-success)

---

## Getting Started

### First Launch

When you first open Chess Master, you'll be greeted with the **Landing Screen** featuring:
- The Chess Master logo with a glowing animation
- App title with stylish effects
- Options to sign in, sign up, or play as a guest
- Feature highlights (Cloud Save, Rankings, Friends)

### Choosing Your Mode

You have two options:

**1. Play as Guest** (Quick Start)
- Tap the "Play as Guest" button in the center
- Start playing immediately
- Progress saved locally on your device
- No cloud sync or friend features

**2. Sign In/Sign Up** (Full Experience)
- Access cloud save features
- Sync progress across devices
- View rankings and leaderboards
- Add and challenge friends

---

## Landing Screen

### Main Features

**Navigation Options:**
- **Sign In** - Top right corner (text button)
- **Sign Up** - Top right corner (elevated button)
- **Play as Guest** - Center button (large, prominent)

**Visual Features:**
- Animated logo with glow effect
- Gradient background from primary color to dark
- Feature badges showing Cloud Save, Rankings, and Friends

**Pro Tip:** If you want to track your progress across devices or compete with friends, create an account. Otherwise, guest mode is perfect for quick practice sessions!

---

## Authentication

### Creating an Account

1. **Tap "Sign Up"** from the landing screen
2. **Enter your email** - Must be a valid email address
3. **Create a password** - Minimum 6 characters
4. **Tap "Sign Up"** - Your account will be created
5. **Confirmation** - You'll see a success message

### Signing In

1. **Tap "Sign In"** from the landing screen
2. **Enter your email and password**
3. **Tap "Sign In"** - You'll be logged in automatically
4. **Progress Sync** - Your cloud progress will load automatically

### Switching Between Sign In/Sign Up

- At the bottom of the auth screen, use the toggle link:
  - "Already have an account? Sign In"
  - "Don't have an account? Sign Up"

### Invite Friends (Sign In Screen Only)

- Tap **"Invite a Friend"** button
- Share link copied to clipboard
- Friends can join and you can challenge them later

---

## Stage Selection

### The Stage Grid

After signing in or choosing guest mode, you'll see the **Stage Selection Screen** with:

**Header Section:**
- App title "CHESS MASTER"
- Settings icon (gear) in the top right
- Total stages completed indicator

**Stage Cards (Grid Layout):**
- 15 stage cards arranged in a grid
- Each card shows:
  - Stage number
  - Difficulty level
  - Lock/unlock status
  - Completion checkmark (if completed)
  - Visual difficulty indicator

### Stage Status Indicators

**🔓 Unlocked Stages:**
- Bright, colorful appearance
- Tap to start playing
- Shows difficulty rating

**🔒 Locked Stages:**
- Grayed out appearance
- Lock icon displayed
- Must complete previous stage to unlock

**✅ Completed Stages:**
- Checkmark badge
- Can replay anytime
- Shows your best performance

### Selecting a Stage

1. **Find an unlocked stage** (not grayed out)
2. **Tap the stage card**
3. **Game screen loads** with AI difficulty set for that stage
4. **Start playing!**

**Note:** You must complete stages in order. Complete Stage 1 to unlock Stage 2, and so on.

---

## Playing a Game

### Game Screen Layout

When you start a game, you'll see:

**Top Section:**
- Back button (←) to return to stage selection
- Stage information (number and difficulty)
- Settings/menu icon

**Center Section:**
- Chess board with pieces
- Your pieces (White) at the bottom
- AI pieces (Black) at the top

**Info Panel (Glassmorphic Container):**
- Current turn indicator
- Captured pieces display
- Game status messages
- Stage information

**Floating Controls (Bottom):**
- Undo button
- Restart button
- Hint button (if available)
- History button

### Making Your First Move

1. **Tap on one of your pieces** (white pieces at bottom)
   - The piece will be highlighted
   - Legal move indicators appear (circles)
   
2. **Tap on a highlighted square** to move
   - Green circles = legal moves
   - Red circle with piece = capture move
   
3. **AI makes its move** automatically
   - Brief animation as AI calculates
   - AI piece moves
   - Your turn begins again

### Understanding Board Highlights

**Visual Indicators:**
- **Selected Piece** - Glowing highlight around your chosen piece
- **Legal Moves** - Green/white circles on valid destination squares
- **Capture Moves** - Red highlight on opponent pieces you can capture
- **Last Move** - Subtle highlight showing the AI's last move
- **Check** - King highlighted in red when in check
- **Threatened Squares** - (Optional) Squares attacked by opponent

---

## Game Controls & Features

### Undo Move

**Icon:** ↶ (curved arrow)

**How to Use:**
1. Tap the "Undo" button
2. Your last move is reversed
3. AI's last move is also reversed
4. You get another chance to move

**Limitations:**
- Limited number of undos per stage
- Undo count shown in settings
- Early stages have more undos
- Advanced stages have fewer or none

**When to Use:**
- You made a mistake
- Want to try a different strategy
- Missed a better opportunity

### Restart Game

**Icon:** ⟲ (circular arrows)

**How to Use:**
1. Tap the "Restart" button
2. Confirmation dialog appears
3. Tap "Restart" to confirm
4. Board resets to starting position

**Use Cases:**
- Completely lost position
- Want to try new opening
- Practice specific scenarios

### Hint System

**Icon:** 💡 (lightbulb)

**Availability:**
- Available in early stages (1-6)
- Limited or unavailable in advanced stages (7-15)
- Helps beginners learn good moves

**How to Use:**
1. Tap the "Hint" button
2. Wait for AI calculation (shows loading)
3. Recommended move is highlighted:
   - Source square glows
   - Destination square glows
   - Arrow may show movement path
4. You can choose to follow or ignore the hint

**What Hints Show:**
- Best tactical move
- Capturing opportunities
- Defensive moves when in danger
- Strategic positioning

### Move History

**Icon:** 📋 (clipboard/document)

**How to Use:**
1. Tap the "History" button
2. Bottom sheet slides up
3. Shows all moves in standard notation

**Information Displayed:**
- Move number
- White's move
- Black's move (AI)
- Standard chess notation (e.g., "e4", "Nf3", "O-O")

**Pro Tip:** Study the move history after games to understand what went wrong or right!

---

## Understanding Stages

### Difficulty Progression

Chess Master features **15 progressive difficulty stages**, each harder than the last:

#### **Stages 1-3: Beginner**
- **Stage 1: Random Rookie**
  - AI makes completely random moves
  - Perfect for absolute beginners
  - Learn piece movement without pressure
  - Unlimited undos

- **Stage 2: Occasional Hunter**
  - AI sometimes captures pieces
  - Still mostly random
  - Good for learning basic tactics
  - Many undos available

- **Stage 3: Capture Seeker**
  - AI prefers capturing pieces
  - Avoids obvious blunders
  - Start thinking ahead
  - Several undos available

#### **Stages 4-6: Easy**
- **Stage 4: Material Matcher**
  - Understands piece values
  - Tries to win valuable pieces
  - Basic material counting
  - Limited undos

- **Stage 5: Trade Tactician**
  - Actively seeks favorable trades
  - Won't trade queen for pawn
  - Better position evaluation
  - Few undos

- **Stage 6: Material Master**
  - Consistently gains material
  - Solid tactical awareness
  - Punishes mistakes
  - Very few undos

#### **Stages 7-9: Intermediate**
- **Stage 7: Lookahead Learner**
  - Thinks 2 moves ahead
  - Basic tactical patterns
  - Fork, pin, skewer recognition
  - No hint available

- **Stage 8: Position Player**
  - Positional evaluation
  - Plans multiple moves ahead
  - Controls center
  - Develops pieces well

- **Stage 9: Triple Thinker**
  - Thinks 3 moves ahead
  - Solid tactical combinations
  - Endgame knowledge
  - Challenging opponent

#### **Stages 10-12: Advanced**
- **Stage 10: Alpha-Beta Ace**
  - Advanced search algorithm
  - Strong positional play
  - Deep tactical vision
  - Very difficult

- **Stage 11: Deep Calculator**
  - Thinks 4 moves ahead
  - Excellent tactics
  - Finds complex combinations
  - Expert level

- **Stage 12: Tactical Titan**
  - Near-perfect tactics
  - Rarely makes mistakes
  - Strong in all phases
  - Master level

#### **Stages 13-15: Expert (Boss Levels)**
- **Stage 13: Algorithm Artist**
  - Advanced AI techniques
  - Deep calculation
  - Positional mastery
  - Elite difficulty

- **Stage 14: Quiescence Queen**
  - Transposition tables
  - Quiescence search (sees forced sequences)
  - Nearly perfect play
  - Grandmaster level

- **Stage 15: Chess Master (BOSS)**
  - **THE ULTIMATE CHALLENGE**
  - Strongest AI in the app
  - Maximum search depth
  - All advanced algorithms
  - Beat this to truly master chess!

### How Stages Unlock

- Start with **Stage 1 unlocked**
- **Win a stage** to unlock the next
- **Draws do not unlock** subsequent stages
- Can **replay completed stages** anytime
- **Cannot skip stages** - must complete in order

---

## Game Features Explained

### Pawn Promotion

**What is it?**
When your pawn reaches the opposite end of the board (8th rank), it can be promoted to a more powerful piece.

**How it Works:**
1. Move your pawn to the last rank
2. **Promotion dialog appears** automatically
3. **Choose your piece:**
   - ♛ **Queen** - Most powerful (recommended 99% of the time)
   - ♜ **Rook** - Strong, good for endgames
   - ♝ **Bishop** - Diagonal power
   - ♞ **Knight** - Unique movement
4. Tap your choice
5. Pawn transforms immediately

**Pro Tip:** Almost always choose Queen unless you need a Knight to deliver checkmate or avoid stalemate!

### Special Moves

**Castling:**
- Move your King two squares toward a Rook
- Rook automatically jumps to the other side of the King
- **Conditions:**
  - King and Rook haven't moved
  - No pieces between them
  - King not in check
  - King doesn't pass through check
- **Visual:** Tap King, see special castling move indicators

**En Passant:**
- Special pawn capture
- Happens when opponent pawn moves two squares
- You can capture it "in passing"
- **Visual:** Shows as legal capture move indicator
- Must be done immediately or opportunity lost

### Check, Checkmate, and Draw

**Check:**
- Your King is under attack
- **Visual:** King highlighted in red/orange
- **Sound:** Special "check" sound effect
- **Must respond** by:
  - Moving King to safety
  - Blocking the attack
  - Capturing the attacking piece

**Checkmate:**
- King in check with no legal moves
- **Game Over** - You win or lose
- **Visual:** Dramatic game result dialog
- **Sound:** Victory or defeat music
- Can restart or return to stage selection

**Draw/Stalemate:**
- Game ends in a tie
- **Causes:**
  - Stalemate (no legal moves, not in check)
  - 50-move rule (50 moves without capture/pawn move)
  - Threefold repetition (same position 3 times)
  - Insufficient material (can't checkmate)
- **Visual:** Draw result dialog
- Does not unlock next stage

---

## Settings & Preferences

### Accessing Settings

**From Stage Selection:**
1. Tap the **gear icon** (⚙️) in the top right
2. Settings dialog opens

**Settings Options:**

#### Sound Effects
- **Toggle:** ON/OFF
- **Controls:**
  - Move sounds
  - Capture sounds
  - Check notification
  - Game over music
- **Tip:** Turn off in quiet environments

#### Theme Selection
- **Light Mode** ☀️
  - Bright, clean interface
  - Easier in daylight
  - Gentle on eyes

- **Dark Mode** 🌙
  - Modern, sleek appearance
  - Easier at night
  - Reduces eye strain
  - Default theme

#### Reset Progress
- **Caution:** Deletes ALL progress
- **Warning dialog** before confirming
- **Use Cases:**
  - Start fresh learning journey
  - Let someone else use the app
  - Testing purposes
- **Cannot undo** - be very careful!

### Saving Settings

- Settings **save automatically**
- Applied **immediately**
- Persist across app restarts
- Synced to cloud (if signed in)

---

## Progress Tracking

### Local Progress (Guest Mode)

**What's Saved:**
- Completed stages
- Current stage unlocked
- Settings preferences
- Best performance per stage

**Storage:**
- Saved on your device
- Persists after closing app
- **Not synced** to other devices
- Lost if app data cleared

### Cloud Progress (Signed In)

**What's Synced:**
- All local progress
- Achievement history
- Statistics
- Friends list
- Rankings

**Benefits:**
- **Play on multiple devices**
- **Never lose progress**
- **Compete with friends**
- **View global rankings**

**How Sync Works:**
1. **Automatic** when signed in
2. **On stage completion** - saves to cloud
3. **On app launch** - downloads latest data
4. **Conflict resolution** - keeps highest progress

### Viewing Your Progress

**Stage Selection Screen:**
- **Unlocked stages** vs total (e.g., "6/15 Stages Completed")
- **Checkmarks** on completed stages
- **Visual progression** through the grid

**Statistics (If implemented):**
- Total games played
- Win/loss/draw ratio
- Average moves per game
- Time spent playing

---

## Tips for Success

### For Beginners (Stages 1-6)

1. **Use Hints Generously**
   - Don't be afraid to ask for help
   - Learn from AI suggestions
   - Understand why moves are good

2. **Focus on Not Losing Pieces**
   - Protect your pieces
   - Before moving, check: "Can opponent capture?"
   - Piece values: Pawn=1, Knight=3, Bishop=3, Rook=5, Queen=9

3. **Control the Center**
   - Move pawns to e4, d4, e5, d5
   - Place Knights and Bishops toward center
   - Center control = more options

4. **Develop All Pieces**
   - Don't move the same piece twice early on
   - Get all pieces into the game
   - Don't leave pieces on starting squares

5. **Castle Early**
   - Protects your King
   - Activates your Rook
   - Usually castle kingside (short castle)

### For Intermediate Players (Stages 7-12)

1. **Think Ahead**
   - Calculate 2-3 moves in advance
   - "If I move here, they move there, then I..."
   - Consider opponent's threats

2. **Look for Tactics**
   - **Forks:** Attack two pieces at once (Knights excel here)
   - **Pins:** Piece can't move without exposing valuable piece
   - **Skewers:** Force valuable piece to move, capture behind it
   - **Discovered attacks:** Move one piece, reveal attack from another

3. **Study the Move History**
   - After losing, review what went wrong
   - Look for the critical mistake
   - Learn from patterns

4. **Endgame Basics**
   - King becomes active in endgame
   - Passed pawns are powerful
   - Rook behind passed pawn
   - Opposition in King/pawn endgames

### For Advanced Players (Stages 13-15)

1. **Be Patient**
   - These stages are extremely difficult
   - Expect to lose many times
   - Learn from each game

2. **Opening Preparation**
   - Use consistent opening moves
   - Learn 1-2 openings well
   - e4 or d4 are good starting moves

3. **Calculate Deeply**
   - Look 4-5 moves ahead minimum
   - Check all forcing moves (checks, captures, threats)
   - Verify your calculations

4. **Positional Understanding**
   - Weak squares
   - Pawn structure
   - Piece coordination
   - Space advantage

5. **Take Breaks**
   - Stage 15 is brutal
   - Fresh mind plays better
   - Don't play when tilted

### General Tips

✅ **Practice Regularly** - Consistency beats intensive cramming

✅ **Learn from Losses** - Every loss is a lesson

✅ **Don't Rush** - Take your time to think

✅ **Enjoy the Journey** - Chess is fun, not frustrating!

✅ **Experiment** - Try different strategies

✅ **Use Undo Wisely** - Don't waste them early

✅ **Sound On** - Audio feedback helps awareness

❌ **Don't Skip Stages** - Each teaches important skills

❌ **Don't Give Up** - Boss stages are meant to challenge you

---

## Troubleshooting

### Common Issues

**Q: I can't move my piece**
- Is it your turn? (Check turn indicator)
- Is the move legal? (Only highlighted squares work)
- Is your King in check? (Must respond to check first)

**Q: Game feels too hard**
- Use hint button (if available)
- Use undo to try different moves
- Replay earlier stages for practice
- Take breaks between attempts

**Q: Game feels too easy**
- Progress to next stage
- Try to win without hints or undos
- Challenge yourself to win faster

**Q: Progress not saving**
- Guest mode: Check device storage
- Signed in: Check internet connection
- Try manual sync (if option available)

**Q: Where's my cloud progress?**
- Make sure you're signed in
- Same email on all devices
- Internet connection required
- May take a moment to sync

### Getting Help

- Review this tutorial
- Check the README.md for technical details
- Practice on easier stages first
- Take your time learning

---

## Glossary

**AI** - Artificial Intelligence (your computer opponent)

**Check** - King under attack

**Checkmate** - King under attack with no escape (game over)

**Stalemate** - No legal moves but not in check (draw)

**Material** - Total value of pieces on the board

**Tactics** - Short-term attacking combinations

**Strategy** - Long-term planning and positioning

**Opening** - First ~10 moves of the game

**Middlegame** - Main battle phase

**Endgame** - Final phase with few pieces left

**Fork** - Attack two pieces at once

**Pin** - Piece can't move without exposing more valuable piece

**Skewer** - Attack forcing piece to move, capture piece behind it

**Castling** - Special King + Rook move

**En Passant** - Special pawn capture

**Promotion** - Pawn reaching 8th rank transforms to stronger piece

**Minimax** - AI algorithm for calculating moves

**Alpha-Beta Pruning** - Advanced AI search technique

---

## Conclusion

Congratulations! You now know everything about using **Chess Master**. 

### Your Journey

1. ✅ Start with Stage 1
2. ✅ Learn the controls and interface
3. ✅ Progress through beginner stages
4. ✅ Master tactics in intermediate stages
5. ✅ Conquer advanced stages
6. ✅ **DEFEAT THE BOSS (Stage 15)!** 🏆

### Remember

- **Chess is a skill** - Improvement takes time
- **Every game teaches** - Win or lose
- **Have fun** - It's a game, not a test!
- **Challenge friends** - Sign in to compete
- **Never give up** - You CAN beat Stage 15!

---

**Good luck, and may you become a true Chess Master!** ♚

---

*Last Updated: February 2026*  
*Version: 1.0*  
*For technical documentation, see README.md*
