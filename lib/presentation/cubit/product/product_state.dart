import 'package:echo_stock/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

enum ProductOption {
  nameAz,
  nameZa,
  statusAvailable,
  statusReserved,
  statusOutOfStock,
  stockLow,
}

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductLoading extends ProductState {
  final int? categoryId;
  final bool isShowingOutOfStock;
  final bool isLowStock;

  const ProductLoading({
    this.categoryId,
    this.isShowingOutOfStock = false,
    this.isLowStock = false,
  });

  @override
  List<Object?> get props => [categoryId, isShowingOutOfStock, isLowStock];
}

class ProductInitial extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final int? selectedCategoryId;
  final List<String> selectedClassification;
  final List<ProductStatus> selectedStatus;
  final bool isCategoryFiltered;
  final ProductOption sortOption;
  final bool isShowingOutOfStock;
  final bool isShowingReserved;
  final bool isLowStockFilter;

  const ProductLoaded(
    this.products,
    this.filteredProducts,
    this.selectedCategoryId,
    this.selectedClassification,
    this.selectedStatus,
    this.isCategoryFiltered,
    this.sortOption,
    this.isShowingOutOfStock,
    this.isShowingReserved,
    this.isLowStockFilter,
  );
  @override
  List<Object?> get props => [
    products,
    filteredProducts,
    selectedCategoryId,
    selectedClassification,
    selectedStatus,
    isCategoryFiltered,
    sortOption,
    isShowingOutOfStock,
    isShowingReserved,
    isLowStockFilter,
  ];

  ProductLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    int? Function()? selectedCategoryId,
    List<String>? selectedClassification,
    List<ProductStatus>? selectedStatus,
    bool? isCategoryFiltered,
    ProductOption? sortOption,
    bool? isShowingOutOfStock,
    bool? isShowingReserved,
    bool? isLowStockFilter,
  }) {
    return ProductLoaded(
      products ?? this.products,
      filteredProducts ?? this.filteredProducts,
      selectedCategoryId != null
          ? selectedCategoryId()
          : this.selectedCategoryId,
      selectedClassification ?? this.selectedClassification,
      selectedStatus ?? this.selectedStatus,
      isCategoryFiltered ?? this.isCategoryFiltered,
      sortOption ?? this.sortOption,
      isShowingOutOfStock ?? this.isShowingOutOfStock,
      isShowingReserved ?? this.isShowingReserved,
      isLowStockFilter ?? this.isLowStockFilter,
    );
  }
}

class ProductActionSucces extends ProductState {
  final String message;
  const ProductActionSucces(this.message);
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
