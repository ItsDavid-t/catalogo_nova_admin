import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _superBaseClient;

  ProductRepositoryImpl(this._superBaseClient);

  //Para obtener todos los productos
  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final response = await _superBaseClient.from('Product').select();
      final List<Product> products = (response as List)
          .map((element) => Product.fromMap(element))
          .toList();
      return Right(products);
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  //Para obtener los producto según su categoría
  @override
  Future<Either<Failure, List<Product>>> getProductsByCategories(
    int categoryId,
  ) async {
    try {
      final categoryIds = await _fetchCategoryAndDescendants(categoryId);

      final response = await _superBaseClient
          .from('Product')
          .select()
          .inFilter('categoryId', categoryIds);
      final List<Product> products = (response as List)
          .map((element) => Product.fromMap(element))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  //Para obtener apartir de una categoria principal todas sus subcategorias

  Future<List<int>> _fetchCategoryAndDescendants(int categoryId) async {
    final categoryIds = <int>{categoryId};
    final queue = <int>[categoryId];

    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      final response = await _superBaseClient
          .from('Category')
          .select('id')
          .eq('parentId', currentId);
      final subCategoryIds = (response as List)
          .map((category) => category['id'] as int)
          .toList();

      for (final id in subCategoryIds) {
        if (categoryIds.add(id)) {
          queue.add(id);
        }
      }
    }

    return categoryIds.toList();
  }

  //Para obtener los productos agotados
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

  //Para obtener los productos agotados pero esta vez filtrados por su categoria
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

  //Para añadir un prodcuto le quito el id porq es autoincremental
  @override
  Future<Either<Failure, Unit>> addProduct(Product product) async {
    try {
      final data = product.toMap();
      data.remove('id');
      await _superBaseClient.from('Product').insert(data);
      return Right(unit);
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      if (e.toString().contains('UNIQUE')) {
        return Left(ValidationFailure('Ese nombre de producto ya existe'));
      }
      return Left(DatabaseFailure('Error al guardar a la nube'));
    }
  }

  //Aqui archivo un producto le paso el id y lo pongo en estado de reserva
  @override
  Future<Either<Failure, Unit>> archiveProduct(int id) async {
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
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  //Para eliminar el producto pero tambien elimino la imagen para q no se llene el supabase
  //y tambien elimino la categoria si este era el ultimo producto conesta
  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure("ID del producto inválido"));
    }
    try {
      final productResponse = await _superBaseClient
          .from('Product')
          .select()
          .eq('id', id)
          .single();
      final product = Product.fromMap(productResponse);

      await _superBaseClient.from('Product').delete().eq('id', id);

      if (product.categoryId != null) {
        await _cleanupOrphanedCategory(product.categoryId!);
      }

      if (product.imgUrl.isNotEmpty) {
        await _deleteProductImage(product.imgUrl);
      }

      return Right(unit);
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  //
  Future<void> _cleanupOrphanedCategory(int categoryId) async {
    final hasProducts = await _hasProductsForCategory(categoryId);
    final hasChildren = await _hasSubcategories(categoryId);

    if (hasProducts || hasChildren) {
      return;
    }

    final response = await _superBaseClient
        .from('Category')
        .select()
        .eq('id', categoryId)
        .single();
    final category = Category.fromMap(response);

    await _superBaseClient.from('Category').delete().eq('id', categoryId);

    if (category.parentId != null) {
      await _cleanupOrphanedCategory(category.parentId!);
    }
  }

  Future<bool> _hasProductsForCategory(int categoryId) async {
    final response = await _superBaseClient
        .from('Product')
        .select('id')
        .eq('categoryId', categoryId)
        .limit(1);
    return (response as List).isNotEmpty;
  }

  Future<bool> _hasSubcategories(int categoryId) async {
    final response = await _superBaseClient
        .from('Category')
        .select('id')
        .eq('parentId', categoryId)
        .limit(1);
    return (response as List).isNotEmpty;
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) async {
    if (product.id == null) {
      return Left(
        ValidationFailure("No se puede actualizar un producto sin ID"),
      );
    }
    try {
      final data = product.toMap();
      data.remove('id');
      await _superBaseClient.from('Product').update(data).eq('id', product.id!);
      return Right(unit);
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        return Left(ValidationFailure('Ese nombre de producto ya existe'));
      }
      return Left(DatabaseFailure('Error al guardar a la nube'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProductImage(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final path =
          'products/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final storage = _superBaseClient.storage.from('product-images');
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: false),
      );
      final publicUrl = storage.getPublicUrl(path);
      return Right(publicUrl);
    } catch (e) {
      developer.log('ERROR DE SUPABASE STORAGE: $e');
      return Left(DatabaseFailure('Error al subir la imagen'));
    }
  }

  Future<void> _deleteProductImage(String imgUrl) async {
    try {
      final uri = Uri.parse(imgUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('product-images');
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final path = pathSegments.sublist(bucketIndex + 1).join('/');
        final storage = _superBaseClient.storage.from('product-images');
        await storage.remove([path]);
      }
    } catch (e) {
      developer.log('Error deleting image: $e');
    }
  }
}
