import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/domain/repositories/shop_profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpsertShopProfile {
  final ShopProfileRepository _repository;

  UpsertShopProfile(this._repository);

  Future<Either<Failure, Unit>> call(ShopProfile profile) {
    return _repository.upsert(profile);
  }
}
