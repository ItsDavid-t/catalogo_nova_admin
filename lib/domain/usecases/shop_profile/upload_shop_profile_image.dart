import 'dart:typed_data';

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/shop_profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class UploadShopProfileImage {
  final ShopProfileRepository _repository;

  UploadShopProfileImage(this._repository);

  Future<Either<Failure, String>> call(Uint8List bytes, String fileName) async {
    return await _repository.uploadLogo(bytes, fileName);
  }
}
