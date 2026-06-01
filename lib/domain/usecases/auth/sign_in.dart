import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:echo_stock/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignIn {
  final AuthRepository _repository;

  SignIn(this._repository);

  Future<Either<Failure, UserSession>> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
