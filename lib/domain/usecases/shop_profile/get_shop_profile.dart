import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/domain/repositories/shop_profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetShopProfile {
  final ShopProfileRepository _repository;

  GetShopProfile(this._repository);

  Future<Either<Failure, ShopProfile?>> call(String userId) {
    return _repository.getByUserId(userId);
  }
}
