import '../../domain/entities/tratamiento.dart';
import '../../domain/repositories/tratamientos_repository.dart';
import '../datasources/tratamientos_remote_datasource.dart';

class TratamientosRepositoryImpl implements TratamientosRepository {
  final TratamientosRemoteDataSource _remote;
  TratamientosRepositoryImpl({required TratamientosRemoteDataSource remote}) : _remote = remote;

  @override Future<List<Tratamiento>> getAll() => _remote.getAll();
  @override Future<List<Tratamiento>> getByAnimal(int bovinoId) => _remote.getByAnimal(bovinoId);
  @override Future<Tratamiento> getOne(int id) => _remote.getOne(id);
  @override Future<Tratamiento> create(Map<String, dynamic> data) => _remote.create(data);
  @override Future<Tratamiento> update(int id, Map<String, dynamic> data) => _remote.update(id, data);
  @override Future<void> delete(int id) => _remote.delete(id);
  @override Future<SeguimientoTratamiento> addSeguimiento(int id, Map<String, dynamic> data) => _remote.addSeguimiento(id, data);
}
