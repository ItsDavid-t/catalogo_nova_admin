import 'dart:developer' as developer;

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:echo_stock/domain/repositories/auth_repository.dart';
import 'package:echo_stock/domain/repositories/invite_code_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final InviteCodeRepository _inviteCodeRepository;

  AuthRepositoryImpl(this._supabase, this._inviteCodeRepository);

  static const _defaultRole = 'employee';

  @override
  Future<Either<Failure, UserSession>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const Left(AuthenticationFailure('No se pudo iniciar sesión'));
      }
      final profile = await _fetchUserProfile(user.id);
      return Right(_toSession(user, profile.role, profile.ownerId));
    } on AuthException catch (e) {
      developer.log('AUTH signIn: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e, st) {
      developer.log('AUTH signIn error', error: e, stackTrace: st);
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, UserSession>> signUp({
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    try {
      final codeResult = await _inviteCodeRepository.validateCode(
        inviteCode.trim(),
      );

      final codeData = await codeResult.fold(
        (failure) => Future.value(null),
        (data) => Future.value(data),
      );

      if (codeData == null) {
        return const Left(AuthenticationFailure('Código inválido o ya usado'));
      }

      final role = (codeData['role'] as String?)?.toLowerCase() ?? _defaultRole;
      final createdBy = codeData['created_by']?.toString();

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const Left(AuthenticationFailure('No se pudo crear la cuenta'));
      }

      final ownerId = role == 'admin' ? user.id : createdBy;
      developer.log(
        'AUTH signUp: codeData createdBy=$createdBy role=$role ownerIdComputed=$ownerId',
      );
      await _saveUserProfile(user.id, role, ownerId: ownerId);

      // Verify profile was saved with expected ownerId and log result
      try {
        final savedProfile = await _fetchUserProfile(user.id);
        developer.log(
          'AUTH signUp: savedProfile ownerId=${savedProfile.ownerId} role=${savedProfile.role}',
        );
      } catch (e, st) {
        developer.log(
          'AUTH signUp: error fetching saved profile',
          error: e,
          stackTrace: st,
        );
      }

      final markResult = await _inviteCodeRepository.markUsed(
        inviteCode.trim(),
        usedBy: user.id,
      );
      markResult.fold(
        (failure) {
          developer.log('AUTH signUp: markUsed failed: ${failure.message}');
        },
        (_) {
          developer.log(
            'AUTH signUp: invite code marked as used for user ${user.id}',
          );
        },
      );

      if (response.session == null) {
        return const Left(
          AuthenticationFailure(
            'Revisa tu correo para confirmar la cuenta antes de entrar',
          ),
        );
      }

      return Right(_toSession(user, role, ownerId));
    } on AuthException catch (e) {
      developer.log('AUTH signUp: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e, st) {
      developer.log('AUTH signUp error', error: e, stackTrace: st);
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return Right(unit);
    } on AuthException catch (e) {
      developer.log('AUTH signOut: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e, st) {
      developer.log('AUTH signOut error', error: e, stackTrace: st);
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, UserSession?>> getCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = session?.user;
      if (user == null) {
        return const Right(null);
      }
      final profile = await _fetchUserProfile(user.id);
      return Right(_toSession(user, profile.role, profile.ownerId));
    } catch (e, st) {
      developer.log('AUTH getCurrentSession error', error: e, stackTrace: st);
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  @override
  Stream<UserSession?> watchAuthSession() {
    return _supabase.auth.onAuthStateChange
        .asyncMap((event) async {
          final user = event.session?.user;
          if (user == null || user.email == null) return null;
          final profile = await _fetchUserProfile(user.id);
          return _toSession(user, profile.role, profile.ownerId);
        })
        .handleError((error) {
          developer.log('AUTH stream error', error: error);
        });
  }

  UserSession _toSession(User user, String role, String? ownerId) {
    return UserSession(user.email ?? '', user.id, role, ownerId: ownerId);
  }

  Future<({String role, String? ownerId})> _fetchUserProfile(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role, owner_id')
          .eq('user_id', userId)
          .maybeSingle();

      final role =
          (response?['role'] as String?)?.toLowerCase() ?? _defaultRole;
      final ownerId = response?['owner_id']?.toString();
      return (role: role, ownerId: ownerId);
    } catch (e, st) {
      developer.log('ERROR OBTENIENDO PERFIL: $e', error: e, stackTrace: st);
      return (role: _defaultRole, ownerId: null);
    }
  }

  Future<void> _saveUserProfile(
    String userId,
    String role, {
    String? ownerId,
  }) async {
    await _supabase.rpc(
      'create_user_profile',
      params: {'input_user_id': userId, 'input_role': role},
    );

    if (ownerId != null && ownerId.trim().isNotEmpty) {
      await _supabase
          .from('profiles')
          .update({'owner_id': ownerId})
          .eq('user_id', userId);
    }
  }

  Failure _mapAuthException(AuthException exception) {
    final code = exception.code?.toLowerCase() ?? '';
    final message = exception.message.toLowerCase();

    if (code.contains('invalid_credentials') ||
        message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return const AuthenticationFailure(
        'No encontramos una cuenta con ese correo o la contraseña es incorrecta.',
        suggestRegistration: true,
      );
    }
    if (code.contains('user_not_found') || message.contains('user not found')) {
      return const AuthenticationFailure(
        'Este correo no está registrado. Crea una cuenta nueva para continuar.',
        suggestRegistration: true,
      );
    }
    if (code.contains('user_already_registered') ||
        message.contains('already registered')) {
      return const AuthenticationFailure('Ese correo ya está registrado');
    }
    if (code.contains('weak_password') || message.contains('weak password')) {
      return const ValidationFailure('La contraseña es demasiado débil');
    }
    if (message.contains('email not confirmed')) {
      return const AuthenticationFailure(
        'Confirma tu correo antes de iniciar sesión',
      );
    }

    return AuthenticationFailure(exception.message);
  }
}
