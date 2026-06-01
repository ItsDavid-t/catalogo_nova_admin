import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:echo_stock/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentSession {
  final AuthRepository _repository;

  GetCurrentSession(this._repository);

  Future<Either<Failure, UserSession?>> call() {
    return _repository.getCurrentSession();
  }
}
