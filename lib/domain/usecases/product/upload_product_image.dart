import 'dart:typed_data';

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

class UploadProductImage {
  final ProductRepository _repository;

  UploadProductImage(this._repository);

  Future<Either<Failure, String>> call(Uint8List bytes, String fileName) async {
    return await _repository.uploadProductImage(bytes, fileName);
  }
}
