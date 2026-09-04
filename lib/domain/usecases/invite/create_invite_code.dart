import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/invite_code_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateInviteCode {
  final InviteCodeRepository _repo;
  CreateInviteCode(this._repo);

  Future<Either<Failure, Unit>> call({
    required String code,
    required String role,
    required String? createdBy,
  }) {
    return _repo.createCode(code: code, role: role, createdBy: createdBy);
  }
}
