import 'package:flutter_test/flutter_test.dart';
import 'package:chess_master/main.dart';
import 'package:chess_master/providers/stage_provider.dart';

void main() {
  testWidgets('Chess Master app smoke test', (WidgetTester tester) async {
    // Create a stage provider
    final stageProvider = StageProvider();
    await stageProvider.loadProgress();

    // Build our app and trigger a frame
    await tester.pumpWidget(ChessMasterApp(stageProvider: stageProvider));

    // Verify that the app title is displayed
    expect(find.text('Chess Master'), findsOneWidget);
  });
}
