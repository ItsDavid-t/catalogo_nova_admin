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
  Future<Either<Failure, List<Category>>> getAllCategories({
    String? shopId,
  }) async {
    try {
      final response = shopId == null
          ? await _supabase.from('Category').select()
          : await _supabase.from('Category').select().eq('shop_id', shopId);
      final categories = (response as List)
          .map((e) => Category.fromMap(e))
          .toList();
      return Right(categories);
    } on PostgrestException catch (e) {
      developer.log('ERROR DE SUPABASE (Category): ${e.message}');
      return Left(DatabaseFailure(_mapPostgrestMessage(e)));
    } catch (e) {
      developer.log('ERROR DE SUPABASE (Category): $e');
      return Left(DatabaseFailure('Error al cargar categorías'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getMainCategories({
    String? shopId,
  }) async {
    try {
      final response = shopId == null
          ? await _supabase
                .from('Category')
                .select()
                .isFilter('parentId', null)
                .order('name')
          : await _supabase
                .from('Category')
                .select()
                .isFilter('parentId', null)
                .eq('shop_id', shopId)
                .order('name');
      final categories = (response as List)
          .map((e) => Category.fromMap(e))
          .toList();
      return Right(categories);
    } on PostgrestException catch (e) {
      developer.log('ERROR DE SUPABASE (Category): ${e.message}');
      return Left(DatabaseFailure(_mapPostgrestMessage(e)));
    } catch (e) {
      developer.log('ERROR DE SUPABASE (Category): $e');
      return Left(DatabaseFailure('Error al cargar categorías principales'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getSubCategories(
    int parentId, {
    String? shopId,
  }) async {
    try {
      final response = shopId == null
          ? await _supabase
                .from('Category')
                .select()
                .eq('parentId', parentId)
                .order('name')
          : await _supabase
                .from('Category')
                .select()
                .eq('parentId', parentId)
                .eq('shop_id', shopId)
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
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  String _mapPostgrestMessage(PostgrestException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('jwt') || message.contains('permission')) {
      return 'No tienes permiso para ver categorías. Inicia sesión de nuevo.';
    }
    return 'No se pudieron cargar las categorías';
  }
}
