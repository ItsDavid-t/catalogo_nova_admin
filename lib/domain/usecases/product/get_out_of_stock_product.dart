import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetOutOfStockProduct {
  final ProductRepository _repository;

  GetOutOfStockProduct(this._repository);

  Future<Either<Failure, List<Product>>> call() async {
    return await _repository.getOutOfStockProducts();
  }
}
