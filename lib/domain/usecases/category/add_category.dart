import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddCategory {
  final CategoryRepository _repository;

  AddCategory(this._repository);

  Future<Either<Failure, int>> call(Category category) async {
    return await _repository.addCategory(category);
  }
}
