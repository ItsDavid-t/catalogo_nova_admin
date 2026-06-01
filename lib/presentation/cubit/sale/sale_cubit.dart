import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/usecases/sale/create_sale.dart';
import 'package:echo_stock/domain/usecases/sale/get_sales_by_shop.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleCubit extends Cubit<SaleState> {
  final GetSalesByShop _getSalesByShop;
  final CreateSale _createSale;

  SaleCubit(this._getSalesByShop, this._createSale) : super(const SaleInitial());

  Future<void> loadSales(String shopId) async {
    emit(const SaleLoading());
    final result = await _getSalesByShop(shopId);

    result.fold(
      (failure) => emit(SaleFailure(failure.message)),
      (sales) => emit(SaleLoaded(sales)),
    );
  }

  Future<void> createAndRefreshSale(Sale sale) async {
    emit(const SaleCreating());
    final result = await _createSale(sale);

    result.fold(
      (failure) => emit(SaleFailure(failure.message)),
      (created) async {
        await loadSales(created.shopId);
      },
    );
  }
}

