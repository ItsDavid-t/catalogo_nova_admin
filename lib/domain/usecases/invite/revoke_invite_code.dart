import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/invite_code_repository.dart';
import 'package:fpdart/fpdart.dart';

class RevokeInviteCode {
  final InviteCodeRepository _repo;
  RevokeInviteCode(this._repo);

  Future<Either<Failure, Unit>> call(String code) {
    return _repo.revokeCode(code);
  }
}
