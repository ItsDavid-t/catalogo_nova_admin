import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _superBaseClient;

  ProductRepositoryImpl(this._superBaseClient);

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final response = await _superBaseClient.from('Product').select();
      final List<Product> products = (response as List)
          .map((element) => Product.fromMap(element))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategories(
    int categoryId,
  ) async {
    try {
      final response = await _superBaseClient
          .from('Product')
          .select()
          .eq('categoryId', categoryId);
      final List<Product> products = (response as List)
          .map((element) => Product.fromMap(element))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getOutOfStockProducts() async {
    try {
      final response = await _superBaseClient
          .from('Product')
          .select()
          .eq('status', 'outOfStock');
      final List<Product> products = (response as List)
          .map((element) => Product.fromMap(element))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getOutOfStockProductsByCategories(
    int categoryId,
  ) async {
    try {
      final response = await _superBaseClient
          .from('Product')
          .select()
          .eq('status', 'outOfStock')
          .eq('categoryId', categoryId);
      final List<Product> products = (response as List)
          .map((element) => Product.fromMap(element))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addProduct(Product product) async {
    try {
      final data = product.toMap();
      data.remove('id');
      await _superBaseClient.from('Product').insert(data);
      return Right(unit);
    } catch (e) {
      print("ERROR DE SUPABASE: $e");
      if (e.toString().contains('UNIQUE')) {
        return Left(ValidationFailure('Ese nombre de producto ya existe'));
      }
      return Left(DatabaseFailure('Error al guardar a la nube'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure("ID del producto inválido"));
    }
    try {
      await _superBaseClient
          .from('Product')
          .update({'status': 'reserved'})
          .eq('id', id);

      return Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) async {
    if (product.id == null) {
      return Left(
        ValidationFailure("No se puede actualizar un producto sin ID"),
      );
    }
    try {
      await _superBaseClient
          .from('Product')
          .update(product.toMap())
          .eq('id', product.id!);
      return Right(unit);
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        return Left(ValidationFailure('Ese nombre de producto ya existe'));
      }
      return Left(DatabaseFailure('Error al guardar a la nube'));
    }
  }
}
