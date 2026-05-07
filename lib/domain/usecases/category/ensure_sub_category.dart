import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class EnsureSubCategory {
  final CategoryRepository _repository;
  const EnsureSubCategory(this._repository);
  Future<Either<Failure, int>> call(String name, int idP) async {
    final result = await _repository.getSubCategories(idP);

    if (result.isLeft()) {
      return Left(result.getLeft().toNullable()!);
    }

    final categories = result.getOrElse((_) => []);

    final exinting = categories.where(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );

    if (exinting.isNotEmpty) {
      return Right(exinting.first.id ?? 0);
    } else {
      final newCategory = Category(name: name, parentId: idP);
      return await _repository.addCategory(newCategory);
    }
  }
}
