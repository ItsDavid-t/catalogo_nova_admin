import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCategoryById {
  final CategoryRepository _repository;

  GetCategoryById(this._repository);

  Future<Either<Failure, Category>> call(int id) async {
    return await _repository.getCategoryById(id);
  }
}
