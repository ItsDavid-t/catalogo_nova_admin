import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/domain/repositories/shop_profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ExportShopProfileData {
  final ShopProfileRepository _repository;

  ExportShopProfileData(this._repository);

  Future<Either<Failure, String?>> call(ShopProfile profile) {
    return _repository.exportProfileData(profile);
  }
}
