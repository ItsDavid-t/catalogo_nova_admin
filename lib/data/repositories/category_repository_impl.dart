import 'dart:developer' as developer;
import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseClient _supabase;

  CategoryRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final response = await _supabase.from('Category').select();
      final categories = (response as List)
          .map((e) => Category.fromMap(e))
          .toList();
      return Right(categories);
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure("Error de conexión"));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getMainCategories() async {
    try {
      final response = await _supabase
          .from('Category')
          .select()
          .isFilter('parentId', null)
          .order('name');
      final categories = (response as List)
          .map((e) => Category.fromMap(e))
          .toList();
      return Right(categories);
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure("Error de conexión"));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getSubCategories(int parentId) async {
    try {
      final response = await _supabase
          .from('Category')
          .select()
          .eq('parentId', parentId)
          .order('name');
      final categories = (response as List)
          .map((e) => Category.fromMap(e))
          .toList();
      return Right(categories);
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure("Error de conexión"));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure("ID de categoría inválido"));
    }
    try {
      final response = await _supabase
          .from('Category')
          .select()
          .eq('id', id)
          .single();

      return Right(Category.fromMap(response));
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure("Error de conexión"));
    }
  }

  @override
  Future<Either<Failure, int>> addCategory(Category category) async {
    try {
      final data = category.toMap();
      data.remove('id');
      final response = await _supabase
          .from('Category')
          .insert(data)
          .select('id')
          .single();
      return Right(response['id'] as int);
    } catch (e) {
      print("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure("Error de conexión"));
    }
  }
}
