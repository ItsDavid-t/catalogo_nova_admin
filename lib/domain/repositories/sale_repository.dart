import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/core/filters/sale_filters.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:fpdart/fpdart.dart';

abstract class SaleRepository {
  Future<Either<Failure, List<Sale>>> getSalesByShop(
    String shopId, {
    SalesFilter? filter,
  });

  Future<Either<Failure, Sale>> createSale(Sale sale);
}
