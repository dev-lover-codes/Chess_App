import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class MoveHistoryWidget extends StatelessWidget {
  const MoveHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final moves = gameProvider.state.engine.moveHistory;
        
        if (moves.isEmpty) {
          return Center(
            child: Text(
              'No moves yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: (moves.length / 2).ceil(),
          itemBuilder: (context, index) {
            final moveNumber = index + 1;
            final whiteMove = moves[index * 2];
            final blackMove = index * 2 + 1 < moves.length ? moves[index * 2 + 1] : null;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 35,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '$moveNumber.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Show white's move on board with green arrow
                        gameProvider.showHistoryMoveOnBoard(whiteMove);
                        // Auto-clear after 3 seconds
                        Future.delayed(const Duration(seconds: 3), () {
                          gameProvider.clearHighlightedMove();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          whiteMove.toAlgebraic(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                        ),
                      ),
                    ),
                  ),
                  if (blackMove != null)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Show black's move on board with green arrow
                          gameProvider.showHistoryMoveOnBoard(blackMove);
                          // Auto-clear after 3 seconds
                          Future.delayed(const Duration(seconds: 3), () {
                            gameProvider.clearHighlightedMove();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Text(
                            blackMove.toAlgebraic(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
