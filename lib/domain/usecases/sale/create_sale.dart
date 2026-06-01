import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/repositories/sale_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateSale {
  final SaleRepository _repository;

  CreateSale(this._repository);

  Future<Either<Failure, Sale>> call(Sale sale) {
    return _repository.createSale(sale);
  }
}
