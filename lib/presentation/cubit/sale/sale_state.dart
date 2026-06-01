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

