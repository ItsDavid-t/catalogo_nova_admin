import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/repositories/sale_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSalesByShop {
  final SaleRepository _repository;

  GetSalesByShop(this._repository);

  Future<Either<Failure, List<Sale>>> call(String shopId) {
    return _repository.getSalesByShop(shopId);
  }
}
