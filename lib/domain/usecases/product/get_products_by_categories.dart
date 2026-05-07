import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetProductsByCategories {
  final ProductRepository _repository;
  GetProductsByCategories(this._repository);

  Future<Either<Failure, List<Product>>> call(int categoryId) async {
    return await _repository.getProductsByCategories(categoryId);
  }
}
