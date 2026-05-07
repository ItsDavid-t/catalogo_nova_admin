import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetMainCategories {
  final CategoryRepository _repository;

  GetMainCategories(this._repository);

  Future<Either<Failure, List<Category>>> call() async {
    return await _repository.getMainCategories();
  }
}
