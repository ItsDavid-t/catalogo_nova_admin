import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:fpdart/fpdart.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAllCategories({String? shopId});
  Future<Either<Failure, Category>> getCategoryById(int id);
  Future<Either<Failure, int>> addCategory(Category category);
  Future<Either<Failure, List<Category>>> getMainCategories({String? shopId});
  Future<Either<Failure, List<Category>>> getSubCategories(
    int parentId, {
    String? shopId,
  });
}
