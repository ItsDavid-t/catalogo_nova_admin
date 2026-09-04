import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/invite_code_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkInviteCodeUsed {
  final InviteCodeRepository _repo;
  MarkInviteCodeUsed(this._repo);

  Future<Either<Failure, Unit>> call(String code, {String? usedBy}) {
    return _repo.markUsed(code, usedBy: usedBy);
  }
}
