import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.signOut();
  }
}
