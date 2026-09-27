import 'package:flutter_test/flutter_test.dart';

import 'package:colorland/coloring/coloring_controller.dart';
import 'package:colorland/main.dart';

void main() {
  testWidgets('Home opens the fox canvas', (WidgetTester tester) async {
    final controllers = await tester.runAsync(loadControllers);
    await tester.pumpWidget(MyApp(controllers: controllers!));

    expect(find.text("Let's color!"), findsOneWidget);
    expect(find.text('NEW PICTURE'), findsOneWidget);

    await tester.tap(find.text('Fox'));
    await tester.pumpAndSettle();

    expect(find.text('0 / 15'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });
}
