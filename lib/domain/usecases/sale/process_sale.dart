import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/entities/sale_item.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:echo_stock/domain/usecases/sale/create_sale.dart';
import 'package:fpdart/fpdart.dart';

class ValidateSaleStock {
  final ProductRepository _productRepository;

  ValidateSaleStock(this._productRepository);

  Future<Either<Failure, Unit>> call(List<SaleItem> items) async {
    for (final item in items) {
      final result = await _productRepository.getProductById(item.productId);
      switch (result) {
        case Left(value: final failure):
          return Left(failure);
        case Right(value: final product):
          if (product.stock < item.quantity) {
            return Left(
              ValidationFailure(
                'Stock insuficiente para "${product.name}" (disponible: ${product.stock})',
              ),
            );
          }
      }
    }
    return const Right(unit);
  }
}

class DecrementStockForSale {
  final ProductRepository _productRepository;

  DecrementStockForSale(this._productRepository);

  Future<Either<Failure, Unit>> call(List<SaleItem> items) async {
    for (final item in items) {
      final result = await _productRepository.decrementProductStock(
        item.productId,
        item.quantity,
      );
      switch (result) {
        case Left(value: final failure):
          return Left(failure);
        case Right():
          break;
      }
    }
    return const Right(unit);
  }
}

class ProcessSale {
  final CreateSale _createSale;
  final ValidateSaleStock _validateSaleStock;
  final DecrementStockForSale _decrementStockForSale;

  ProcessSale(
    this._createSale,
    this._validateSaleStock,
    this._decrementStockForSale,
  );

  Future<Either<Failure, Sale>> call(Sale sale) async {
    final validation = await _validateSaleStock(sale.items);
    switch (validation) {
      case Left(value: final failure):
        return Left(failure);
      case Right():
        break;
    }

    final saleResult = await _createSale(sale);
    switch (saleResult) {
      case Left(value: final failure):
        return Left(failure);
      case Right(value: final created):
        final stockResult = await _decrementStockForSale(created.items);
        return stockResult.fold(
          Left.new,
          (_) => Right(created),
        );
    }
  }
}
