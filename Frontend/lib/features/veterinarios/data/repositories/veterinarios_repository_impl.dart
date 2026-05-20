import '../../domain/entities/veterinario.dart';
import '../../domain/repositories/veterinarios_repository.dart';
import '../datasources/veterinarios_remote_datasource.dart';

class VeterinariosRepositoryImpl implements VeterinariosRepository {
  final VeterinariosRemoteDataSource _remote;
  VeterinariosRepositoryImpl({required VeterinariosRemoteDataSource remote}) : _remote = remote;

  @override Future<List<Veterinario>> getAll() => _remote.getAll();
  @override Future<Veterinario> getOne(int id) => _remote.getOne(id);
  @override Future<Veterinario> create(Map<String, dynamic> data) => _remote.create(data);
  @override Future<Veterinario> update(int id, Map<String, dynamic> data) => _remote.update(id, data);
  @override Future<void> delete(int id) => _remote.delete(id);
}
