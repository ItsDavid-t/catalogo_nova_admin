import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

class ArchiveProduct {
  final ProductRepository _repository;
  ArchiveProduct(this._repository);

  Future<Either<Failure, Unit>> call(int id) async {
    return await _repository.archiveProduct(id);
  }
}
