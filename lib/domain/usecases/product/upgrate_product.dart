import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpgrateProduct {
  final ProductRepository _repository;
  UpgrateProduct(this._repository);

  Future<Either<Failure, Unit>> call(Product product) async {
    return await _repository.updateProduct(product);
  }
}
