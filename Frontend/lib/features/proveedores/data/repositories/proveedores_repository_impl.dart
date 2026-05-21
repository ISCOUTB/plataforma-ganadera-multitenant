import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedores_repository.dart';
import '../datasources/proveedores_remote_datasource.dart';

class ProveedoresRepositoryImpl implements ProveedoresRepository {
  final ProveedoresRemoteDataSource _remote;
  ProveedoresRepositoryImpl({required ProveedoresRemoteDataSource remote}) : _remote = remote;

  @override Future<List<Proveedor>> getAll() => _remote.getAll();
  @override Future<Proveedor> getOne(int id) => _remote.getOne(id);
  @override Future<Proveedor> create(Map<String, dynamic> data) => _remote.create(data);
  @override Future<Proveedor> update(int id, Map<String, dynamic> data) => _remote.update(id, data);
  @override Future<void> delete(int id) => _remote.delete(id);
  @override Future<ProveedorPrecio> addPrecio(int id, Map<String, dynamic> data) => _remote.addPrecio(id, data);
  @override Future<void> deletePrecio(int precioId) => _remote.deletePrecio(precioId);
  @override Future<List<ProveedorPrecio>> getComparador(String fkIdAlimento) => _remote.getComparador(fkIdAlimento);
}