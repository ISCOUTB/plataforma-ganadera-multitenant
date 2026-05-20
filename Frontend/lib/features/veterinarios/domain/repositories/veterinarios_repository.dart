import '../entities/veterinario.dart';

abstract class VeterinariosRepository {
  Future<List<Veterinario>> getAll();
  Future<Veterinario> getOne(int id);
  Future<Veterinario> create(Map<String, dynamic> data);
  Future<Veterinario> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
