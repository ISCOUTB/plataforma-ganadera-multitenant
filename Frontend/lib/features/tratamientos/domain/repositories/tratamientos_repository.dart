import '../entities/tratamiento.dart';

abstract class TratamientosRepository {
  Future<List<Tratamiento>> getAll();
  Future<List<Tratamiento>> getByAnimal(int bovinoId);
  Future<Tratamiento> getOne(int id);
  Future<Tratamiento> create(Map<String, dynamic> data);
  Future<Tratamiento> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
  Future<SeguimientoTratamiento> addSeguimiento(int id, Map<String, dynamic> data);
}
