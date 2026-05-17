import 'package:echo_stock/domain/core/failures.dart';
import 'dart:typed_data';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, List<Product>>> getOutOfStockProducts();
  Future<Either<Failure, List<Product>>> getOutOfStockProductsByCategories(
    int categoryId,
  );
  Future<Either<Failure, Unit>> addProduct(Product product);
  Future<Either<Failure, Unit>> deleteProduct(int id);
  Future<Either<Failure, Unit>> updateProduct(Product product);
  Future<Either<Failure, String>> uploadProductImage(
    Uint8List bytes,
    String fileName,
  );
  Future<Either<Failure, List<Product>>> getProductsByCategories(
    int categoryId,
  );
}
