import '../entities/cita.dart';

abstract class CitasRepository {
  Future<List<Cita>> getAll();
  Future<List<Cita>> getProximas({int dias});
  Future<Cita> getOne(int id);
  Future<Cita> create(Map<String, dynamic> data);
  Future<Cita> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
