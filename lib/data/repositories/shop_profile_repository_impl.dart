import 'dart:developer' as developer;

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/domain/repositories/shop_profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopProfileRepositoryImpl implements ShopProfileRepository {
  final SupabaseClient _supabase;

  ShopProfileRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, ShopProfile?>> getByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('shop_profile')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response == null) {
        return const Right(null);
      }
      return Right(ShopProfile.fromMap(response));
    } catch (e) {
      developer.log('ERROR DE SUPABASE (shop_profile): $e');
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsert(ShopProfile profile) async {
    try {
      final data = profile.toMap();
      await _supabase.from('shop_profile').upsert(data);
      return Right(unit);
    } catch (e) {
      developer.log('ERROR DE SUPABASE (shop_profile): $e');
      return Left(DatabaseFailure('Error al guardar el perfil de tienda'));
    }
  }
}
