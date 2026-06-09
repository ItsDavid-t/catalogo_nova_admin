import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSubCategories {
  final CategoryRepository _repository;

  GetSubCategories(this._repository);
  Future<Either<Failure, List<Category>>> call(
    int parentId, {
    String? shopId,
  }) async {
    return await _repository.getSubCategories(parentId, shopId: shopId);
  }
}
