import '../entities/proveedor.dart';

abstract class ProveedoresRepository {
  Future<List<Proveedor>> getAll();
  Future<Proveedor> getOne(int id);
  Future<Proveedor> create(Map<String, dynamic> data);
  Future<Proveedor> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
  Future<ProveedorPrecio> addPrecio(int id, Map<String, dynamic> data);
  Future<void> deletePrecio(int precioId);
  Future<List<ProveedorPrecio>> getComparador(String fkIdAlimento);
}