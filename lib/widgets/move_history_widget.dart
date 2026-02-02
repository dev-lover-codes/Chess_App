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
          itemCount: (moves.length / 2).ceil(),
          itemBuilder: (context, index) {
            final moveNumber = index + 1;
            final whiteMove = moves[index * 2];
            final blackMove = index * 2 + 1 < moves.length ? moves[index * 2 + 1] : null;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$moveNumber.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      whiteMove.toStandardNotation(gameProvider.state.engine.board),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (blackMove != null)
                    Expanded(
                      child: Text(
                        blackMove.toStandardNotation(gameProvider.state.engine.board),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
