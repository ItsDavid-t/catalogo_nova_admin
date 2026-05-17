import 'dart:developer' as developer;
import 'dart:typed_data';

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
      developer.log("ERROR DE SUPABASE: $e");
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
      developer.log("ERROR DE SUPABASE: $e");
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
      final productResponse = await _superBaseClient
          .from('Product')
          .select()
          .eq('id', id)
          .single();
      final product = Product.fromMap(productResponse);

      await _superBaseClient.from('Product').delete().eq('id', id);

      if (product.categoryId != null) {
        final remainingProducts = await _superBaseClient
            .from('Product')
            .select('id')
            .eq('categoryId', product.categoryId!)
            .limit(1);
        if (remainingProducts.isEmpty) {
          await _superBaseClient
              .from('Category')
              .delete()
              .eq('id', product.categoryId!);
        }
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
      // Parse the path from the public URL
      // URL format: https://xxx.supabase.co/storage/v1/object/public/product-images/path/to/file
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
      // Don't fail the entire operation if image deletion fails
    }
  }
}
