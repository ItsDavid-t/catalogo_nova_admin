import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllCategories {
  final CategoryRepository _repository;

  GetAllCategories(this._repository);
  Future<Either<Failure, List<Category>>> call({String? shopId}) async {
    return await _repository.getAllCategories(shopId: shopId);
  }
}
