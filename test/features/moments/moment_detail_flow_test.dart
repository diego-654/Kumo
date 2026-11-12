import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kumo/features/moments/data/repositories/in_memory_moments_repository.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/screens/moment_form_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  final moment = Moment(
    id: '1',
    placeName: 'Café Central',
    note: 'Tranquilo y acogedor',
    createdAt: DateTime(2026, 10, 20),
    sentiment: const Sentiment(emotion: Emotion.calma, confidence: 0.9),
  );

  Future<InMemoryMomentsRepository> openDetail(WidgetTester tester) async {
    final repository = InMemoryMomentsRepository(seed: [moment]);
    await tester.pumpKumoApp(momentsRepository: repository);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Momentos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Café Central'));
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('borrar pide confirmación y quita el momento', (tester) async {
    final repository = await openDetail(tester);

    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar este momento?'), findsOneWidget);

    // Cancelar no borra nada.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await repository.getMoments(), [moment]);

    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar').last); // el del diálogo
    await tester.pumpAndSettle();

    expect(await repository.getMoments(), isEmpty);
    expect(find.text('Aún no hay momentos'), findsOneWidget);
  });

  testWidgets('sin ubicación no ofrece "Ver en mapa"', (tester) async {
    await openDetail(tester);

    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Ver en mapa'), findsNothing);
  });

  testWidgets('se puede corregir la emoción que detectó la IA', (
    tester,
  ) async {
    final repository = await openDetail(tester);

    await tester.tap(find.text('Corregir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nostalgia'));
    await tester.pumpAndSettle();

    final saved = await repository.getMomentById('1');
    expect(saved?.sentiment?.emotion, Emotion.nostalgia);
    expect(saved?.sentiment?.correctedByUser, isTrue);
    expect(find.text('Corregiste la emoción a Nostalgia'), findsOneWidget);
  });

  testWidgets('el botón de cámara abre el formulario', (tester) async {
    await tester.pumpKumoApp();
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Registrar un momento'));
    await tester.pumpAndSettle();

    expect(find.byType(MomentFormScreen), findsOneWidget);
  });
}
