import 'dart:developer' as developer;
import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseClient _supabase;
  List<Category> _toCategories(List data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(Category.fromMap)
        .toList();
  }

  static const _table = 'Category';

  CategoryRepositoryImpl(this._supabase);

  PostgrestFilterBuilder _baseQuery({String? shopId}) {
    var query = _supabase.from(_table).select();

    if (shopId != null) {
      query = query.eq('shop_id', shopId);
    }

    return query;
  }

  @override
  Future<Either<Failure, List<Category>>> getAllCategories({
    String? shopId,
  }) async {
    try {
      final response = await _baseQuery(shopId: shopId);
      return Right(_toCategories(response));
    } on PostgrestException catch (e) {
      developer.log('ERROR DE SUPABASE (Category): ${e.message}');
      return Left(DatabaseFailure(_mapPostgrestMessage(e)));
    } catch (e, st) {
      developer.log('ERROR DE SUPABASE', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error al cargar categorías'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getMainCategories({
    String? shopId,
  }) async {
    try {
      final response = await _baseQuery(
        shopId: shopId,
      ).isFilter('parent_id', null).order('name');
      return Right(_toCategories(response));
    } on PostgrestException catch (e) {
      developer.log('ERROR DE SUPABASE (Category): ${e.message}');
      return Left(DatabaseFailure(_mapPostgrestMessage(e)));
    } catch (e, st) {
      developer.log('ERROR DE SUPABASE', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error al cargar categorías principales'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getSubCategories(
    int parentId, {
    String? shopId,
  }) async {
    try {
      final response = await _baseQuery(
        shopId: shopId,
      ).eq('parent_id', parentId).order('name');
      return Right(_toCategories(response));
    } catch (e, st) {
      developer.log('ERROR DE SUPABASE', error: e, stackTrace: st);
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
          .from(_table)
          .select()
          .eq('id', id)
          .single();

      return Right(Category.fromMap(response));
    } catch (e, st) {
      developer.log('ERROR DE SUPABASE', error: e, stackTrace: st);
      return Left(DatabaseFailure("Error de conexión"));
    }
  }

  // vefifico si existe la categoria son el ilike(tambien valido q esten en tiendas distintas y q tengan padres distintos)
  @override
  Future<Either<Failure, int>> addCategory(Category category) async {
    try {
      final name = category.name.trim();
      var query = _supabase.from(_table).select();
      query = query.ilike('name', name);
      if (category.shopId != null) {
        query = query.eq('shop_id', category.shopId!);
      }
      // Evita duplicados dentro del mismo nivel jerárquico.
      // Se permite repetir nombres en ramas distintas.
      if (category.parentId == null) {
        query = query.isFilter('parent_id', null);
      } else {
        query = query.eq('parent_id', category.parentId!);
      }

      final existing = await query;
      final existingList = existing as List;
      if (existingList.isNotEmpty) {
        return Left(
          ValidationFailure('Ya existe una categoría con ese nombre'),
        );
      }

      final data = category.toMap();
      data.remove('id');
      data['name'] = name;
      final response = await _supabase
          .from(_table)
          .insert(data)
          .select('id')
          .single();
      return Right(response['id'] as int);
    } on PostgrestException catch (e) {
      developer.log("ERROR DE SUPABASE (Category): ${e.message}");
      return Left(DatabaseFailure(_mapPostgrestMessage(e)));
    } catch (e, st) {
      developer.log('ERROR DE SUPABASE', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  ///convierte los errores de supabase en mensajes mas legibles para mi
  String _mapPostgrestMessage(PostgrestException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('jwt') || message.contains('permission')) {
      return 'No tienes permiso para ver categorías. Inicia sesión de nuevo.';
    }
    return 'No se pudieron cargar las categorías';
  }
}
