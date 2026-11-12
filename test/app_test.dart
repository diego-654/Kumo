import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kumo/features/heat_map/presentation/screens/heat_map_screen.dart';

import 'helpers/pump_app.dart';

void main() {
  // main.dart lo hace antes de runApp; las fechas en español lo necesitan.
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('arranca en el mapa y navega a Momentos', (tester) async {
    await tester.pumpKumoApp();
    await tester.pumpAndSettle();

    expect(find.byType(HeatMapScreen), findsOneWidget);

    await tester.tap(find.text('Momentos'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay momentos'), findsOneWidget);
  });
}
