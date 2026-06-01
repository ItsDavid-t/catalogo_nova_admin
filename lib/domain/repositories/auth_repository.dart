import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserSession>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserSession>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, UserSession?>> getCurrentSession();

  Stream<UserSession?> watchAuthSession();
}
