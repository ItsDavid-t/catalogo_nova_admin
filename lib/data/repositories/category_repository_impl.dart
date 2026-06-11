import 'dart:developer' as developer;
import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseClient _supabase;

  CategoryRepositoryImpl(this._supabase);

  //Para obtener todas las categorias(filtra por shop_id para obtener las categorias de cada user)
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

  //Para obtener las categorias principales (q se filtra por parentId y shop_id en caso de q este ultimo no se null y lo ordeno por nombre),
  //solo va a retonar las categorias no las subcategorias
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

  //Para obtener las subCategorias (q se filtra por parentId en caso de q no sea null y shop_id en caso de q este ultimo no se null y lo ordeno por nombre),
  // solo va a retonar las subcategorias
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

  //Para obenter las categorias por Id, esto basicamente lo uso para el filtrado, le paso el id al metodo y este me retorna la categorias con ese id
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

  //Para añadir una categoria, en caso de q se cree un id lo remuevo porq el id es autoincremental,
  //tambien vefifico si existe la categoria son el ilike(tambien valido q esten en tiendas distintas y q tengan padres distintos)
  @override
  Future<Either<Failure, int>> addCategory(Category category) async {
    try {
      final name = category.name.trim();
      var query = _supabase.from('Category').select();
      query = query.ilike('name', name);
      if (category.shopId != null) {
        query = query.eq('shop_id', category.shopId!);
      }
      if (category.parentId == null) {
        query = query.isFilter('parentId', null);
      } else {
        query = query.eq('parentId', category.parentId!);
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
          .from('Category')
          .insert(data)
          .select('id')
          .single();
      return Right(response['id'] as int);
    } on PostgrestException catch (e) {
      developer.log("ERROR DE SUPABASE (Category): ${e.message}");
      return Left(DatabaseFailure(_mapPostgrestMessage(e)));
    } catch (e) {
      developer.log("ERROR DE SUPABASE: $e");
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  //convierte los errores de supabase en mensajes mas legibles para mi
  String _mapPostgrestMessage(PostgrestException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('jwt') || message.contains('permission')) {
      return 'No tienes permiso para ver categorías. Inicia sesión de nuevo.';
    }
    return 'No se pudieron cargar las categorías';
  }
}
