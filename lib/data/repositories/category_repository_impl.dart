import 'dart:developer' as developer;
import 'package:echo_stock/data/datasources/local_product_data_source.dart';
import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';

import 'package:fpdart/fpdart.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final LocalProductDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final data = await _localDataSource.getAllCategories();
      return Right(data);
    } catch (e, stackTrace) {
      developer.log(
        'Error en getAllCategories: ',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure("Error al cargar las categorías"));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getMainCategories() async {
    try {
      final data = await _localDataSource.getMainCategories();
      return Right(data);
    } catch (e, stackTrace) {
      developer.log(
        'Error en getMainCategories: ',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        DatabaseFailure("Error al cargar las categorías principales"),
      );
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getSubCategories(int parentId) async {
    try {
      final data = await _localDataSource.getSubCategories(parentId);
      return Right(data);
    } catch (e, stackTrace) {
      developer.log(
        'Error en getMainCategories: ',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        DatabaseFailure("Error al cargar las categorías principales"),
      );
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure("ID de categoría inválido"));
    }
    try {
      final data = await _localDataSource.getCategoryById(id);
      return Either.fromNullable(
        data,
        () => NotFoundFailure("Categoría no encontrada"),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error en getCategoryById: ',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure("Error al obtener la categoría"));
    }
  }

  @override
  Future<Either<Failure, int>> addCategory(Category category) async {
    try {
      int id = await _localDataSource.insertCategory(category);
      return Right(id);
    } catch (e, stackTrace) {
      developer.log('Error en addCategory: ', error: e, stackTrace: stackTrace);
      if (e.toString().contains('UNIQUE')) {
        return Left(ValidationFailure('Ese nombre de categoría ya existe'));
      }
      return Left(DatabaseFailure("Error al agregar la categoría"));
    }
  }
}
