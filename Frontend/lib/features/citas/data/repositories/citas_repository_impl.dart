import '../../domain/entities/cita.dart';
import '../../domain/repositories/citas_repository.dart';
import '../datasources/citas_remote_datasource.dart';

class CitasRepositoryImpl implements CitasRepository {
  final CitasRemoteDataSource _remote;
  CitasRepositoryImpl({required CitasRemoteDataSource remote}) : _remote = remote;

  @override Future<List<Cita>> getAll() => _remote.getAll();
  @override Future<List<Cita>> getProximas({int dias = 7}) => _remote.getProximas(dias: dias);
  @override Future<Cita> getOne(int id) => _remote.getOne(id);
  @override Future<Cita> create(Map<String, dynamic> data) => _remote.create(data);
  @override Future<Cita> update(int id, Map<String, dynamic> data) => _remote.update(id, data);
  @override Future<void> delete(int id) => _remote.delete(id);
}
