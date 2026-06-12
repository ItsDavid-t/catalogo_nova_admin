import 'dart:developer' as developer;

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:echo_stock/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  ///Inicio de sesion usando el email y la contraseña
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
      return Right(_toSession(user));
    } on AuthException catch (e) {
      developer.log('AUTH signIn: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e) {
      developer.log('AUTH signIn error: $e');
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  ///Registrase usando email y contraseña
  @override
  Future<Either<Failure, UserSession>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const Left(AuthenticationFailure('No se pudo crear la cuenta'));
      }
      if (response.session == null) {
        return const Left(
          AuthenticationFailure(
            'Revisa tu correo para confirmar la cuenta antes de entrar',
          ),
        );
      }
      return Right(_toSession(user));
    } on AuthException catch (e) {
      developer.log('AUTH signUp: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e) {
      developer.log('AUTH signUp error: $e');
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  ///Cerrar session
  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return Right(unit);
    } on AuthException catch (e) {
      developer.log('AUTH signOut: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e) {
      developer.log('AUTH signOut error: $e');
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  ///Obtener la session actual , asi el user no tiene q registrarse de nuevo
  @override
  Future<Either<Failure, UserSession?>> getCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = session?.user;
      if (user == null) {
        return const Right(null);
      }
      return Right(_toSession(user));
    } catch (e) {
      developer.log('AUTH getCurrentSession error: $e');
      return const Left(NetworkFailure('Error de conexión'));
    }
  }

  ///Escucha los cambios en el estado de autentificacion
  @override
  Stream<UserSession?> watchAuthSession() {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) {
        return null;
      }
      return _toSession(user);
    });
  }

  ///Para convertir un User a un UserSession
  UserSession _toSession(User user) {
    return UserSession(user.email ?? '', user.id);
  }

  ///convierte los errores de supabase en mensajes mas legibles para mi
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
