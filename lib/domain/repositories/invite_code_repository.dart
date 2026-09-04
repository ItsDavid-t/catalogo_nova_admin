import 'package:echo_stock/domain/core/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract class InviteCodeRepository {
  Future<Either<Failure, Unit>> createCode({
    required String code,
    required String role,
    required String? createdBy,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> listCodes();

  Future<Either<Failure, Unit>> revokeCode(String code);

  Future<Either<Failure, Unit>> markUsed(String code, {String? usedBy});

  Future<Either<Failure, Map<String, dynamic>?>> validateCode(String code);
}
