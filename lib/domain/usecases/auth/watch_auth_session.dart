import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:echo_stock/domain/repositories/auth_repository.dart';

class WatchAuthSession {
  final AuthRepository _repository;

  WatchAuthSession(this._repository);

  Stream<UserSession?> call() {
    return _repository.watchAuthSession();
  }
}
