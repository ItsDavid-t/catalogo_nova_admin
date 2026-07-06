import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteProductImage {
  final ProductRepository _repository;

  DeleteProductImage(this._repository);

  Future<Either<Failure, Unit>> call(String imgUrl) async {
    return await _repository.deleteProductImage(imgUrl);
  }
}
