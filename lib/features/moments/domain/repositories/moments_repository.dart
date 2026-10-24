import 'package:kumo/features/moments/domain/entities/moment.dart';

/// Contrato del dominio. La capa de datos lo implementa (memoria, API,
/// Firestore...) y la presentación solo conoce esta interfaz.
abstract interface class MomentsRepository {
  Future<List<Moment>> getMoments();

  /// Devuelve `null` si no existe un momento con ese [id].
  Future<Moment?> getMomentById(String id);

  /// Crea el momento o, si ya existe uno con el mismo `id`, lo reemplaza.
  Future<void> saveMoment(Moment moment);
}
