import 'dart:developer' as developer;

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/invite_code_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InviteCodeRepositoryImpl implements InviteCodeRepository {
  final SupabaseClient _supabase;
  InviteCodeRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, Unit>> createCode({
    required String code,
    required String role,
    required String? createdBy,
  }) async {
    try {
      await _supabase.from('invite_codes').insert({
        'code': code,
        'role': role,
        'created_by': createdBy,
        'status': 'active',
      });
      return Right(unit);
    } catch (e, st) {
      developer.log('invite create error', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error creando código'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listCodes() async {
    try {
      final res = await _supabase
          .from('invite_codes')
          .select(
            'code, role, status, created_by, created_at, used_by, used_at',
          )
          .order('created_at', ascending: false);
      return Right(List<Map<String, dynamic>>.from(res as List));
    } catch (e, st) {
      developer.log('invite list error', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error al listar códigos'));
    }
  }

  @override
  Future<Either<Failure, Unit>> revokeCode(String code) async {
    try {
      await _supabase
          .from('invite_codes')
          .update({'status': 'revoked'})
          .eq('code', code);
      return Right(unit);
    } catch (e, st) {
      developer.log('invite revoke error', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error revocando código'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markUsed(String code, {String? usedBy}) async {
    try {
      await _supabase
          .from('invite_codes')
          .update({
            'status': 'used',
            'used_by': usedBy,
            'used_at': DateTime.now().toIso8601String(),
          })
          .eq('code', code);
      return Right(unit);
    } catch (e, st) {
      developer.log('invite mark used error', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error marcando como usado'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> validateCode(
    String code,
  ) async {
    try {
      final res = await _supabase.rpc(
        'validate_invite_code',
        params: {'input_code': code},
      );
      if (res.isEmpty) {
        return Right(null);
      } else {
        return Right(Map<String, dynamic>.from(res[0] as Map));
      }
    } catch (e, st) {
      developer.log('invite validate error', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error validando código'));
    }
  }
}
