import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kumo/app/app.dart';

void main() {
  testWidgets('arranca en el mapa y navega a Momentos', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KumoApp()));
    await tester.pumpAndSettle();

    expect(find.text('Mapa emocional'), findsOneWidget);

    await tester.tap(find.text('Momentos'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay momentos'), findsOneWidget);
  });
}
