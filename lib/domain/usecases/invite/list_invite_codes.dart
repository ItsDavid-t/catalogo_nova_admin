import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/invite_code_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListInviteCodes {
  final InviteCodeRepository _repo;
  ListInviteCodes(this._repo);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repo.listCodes();
  }
}
