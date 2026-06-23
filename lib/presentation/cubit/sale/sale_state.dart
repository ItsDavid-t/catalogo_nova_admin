import 'package:echo_stock/domain/entities/cart_item.dart';
import 'package:echo_stock/domain/entities/profit_loss.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:equatable/equatable.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {
  const SaleInitial();
}

class SaleLoading extends SaleState {
  const SaleLoading();
}

class SaleLoaded extends SaleState {
  final List<Sale> sales;

  const SaleLoaded(this.sales);

  @override
  List<Object?> get props => [sales];
}

class SaleCreating extends SaleState {
  const SaleCreating();
}

class SaleFailure extends SaleState {
  final String message;

  const SaleFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SaleFinanceLoaded extends SaleState {
  final ProfitLoss profitLoss;

  const SaleFinanceLoaded(this.profitLoss);

  @override
  List<Object?> get props => [profitLoss];
}

class CartUpdated extends SaleState {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CartUpdated({required this.cartItems, required this.totalAmount});

  @override
  List<Object?> get props => [cartItems, totalAmount];
}

class SaleConfirmed extends SaleState {
  final Sale sale;
  final String message;

  const SaleConfirmed(this.sale, this.message);

  @override
  List<Object?> get props => [sale, message];
}
