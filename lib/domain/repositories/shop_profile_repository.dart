import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:fpdart/fpdart.dart';

abstract class ShopProfileRepository {
  Future<Either<Failure, ShopProfile?>> getByUserId(String userId);
  Future<Either<Failure, Unit>> upsert(ShopProfile profile);
}
