import 'package:kumo/features/moments/domain/entities/moment.dart';

/// Contrato del dominio. La capa de datos lo implementa (memoria, API,
/// Firestore...) y la presentación solo conoce esta interfaz.
abstract interface class MomentsRepository {
  Future<List<Moment>> getMoments();
  Future<void> addMoment(Moment moment);
  /// Devuelve `null` si no existe un momento con ese [id].
  Future<Moment?> getMomentById(String id);
}
