import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kumo/app/app.dart';
import 'package:kumo/core/location/location_providers.dart';
import 'package:kumo/features/moments/data/repositories/in_memory_moments_repository.dart';
import 'package:kumo/features/moments/domain/repositories/moments_repository.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';

import 'fake_location_service.dart';

extension PumpKumoApp on WidgetTester {
  /// Monta la app completa con dependencias deterministas: sin momentos y
  /// con un GPS falso.
  ///
  /// Para empezar con datos, pasa [momentsRepository]. No uses [overrides]
  /// para el repositorio: Riverpod no deja sobrescribir el mismo provider
  /// dos veces en un contenedor (lanza un assert).
  Future<void> pumpKumoApp({
    MomentsRepository? momentsRepository,
    List<Override> overrides = const [],
  }) => pumpWidget(
    ProviderScope(
      overrides: [
        momentsRepositoryProvider.overrideWithValue(
          momentsRepository ?? InMemoryMomentsRepository(seed: []),
        ),
        locationServiceProvider.overrideWithValue(
          const FakeLocationService(),
        ),
        ...overrides,
      ],
      child: const KumoApp(),
    ),
  );
}
