import 'dart:typed_data';

import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/usecases/product/add_product.dart';
import 'package:echo_stock/domain/usecases/product/archive_product.dart';
import 'package:echo_stock/domain/usecases/product/delete_product.dart';
import 'package:echo_stock/domain/usecases/product/get_all_products.dart';
import 'package:echo_stock/domain/usecases/product/get_out_of_stock_product.dart';
import 'package:echo_stock/domain/usecases/product/get_products_by_categories.dart';
import 'package:echo_stock/domain/usecases/product/upload_product_image.dart';
import 'package:echo_stock/domain/usecases/product/upgrate_product.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetAllProducts _getAllProducts;
  final AddProduct _addProduct;
  final UpgrateProduct _upgrateProduct;
  final GetOutOfStockProduct _getOutOfStockProduct;
  final UploadProductImage _uploadProductImage;
  final DeleteProduct _deleteProduct;
  final GetProductsByCategories _getProductsByCategories;
  final ArchiveProduct _archiveProduct;

  ProductCubit(
    this._getAllProducts,
    this._addProduct,
    this._upgrateProduct,
    this._getOutOfStockProduct,
    this._uploadProductImage,
    this._deleteProduct,
    this._getProductsByCategories,
    this._archiveProduct,
  ) : super(ProductInitial());

  void reset() {
    emit(ProductInitial());
  }

  Future<void> loadProducts() async {
    emit(ProductLoading(categoryId: null, isShowingOutOfStock: false));

    final result = await _getAllProducts();

    result.fold((failure) => emit(ProductError(failure.message)), (products) {
      final filtered = _applyFilters(
        products,
        null,
        [],
        [],
        ProductOption.nameAz,
        false,
      );

      emit(
        ProductLoaded(
          products,
          filtered,
          null,
          [],
          [],
          false,
          ProductOption.nameAz,
          false,
          false,
        ),
      );
    });
  }

  Future<void> loadProductsByCategories(int? categoryId) async {
    if (categoryId == null) {
      loadProducts();
      return;
    }
    emit(ProductLoading(isShowingOutOfStock: false, categoryId: categoryId));
    final result = await _getProductsByCategories(categoryId);

    result.fold(
      (failure) {
        emit(ProductError(failure.message));
      },
      (products) {
        final filtered = _applyFilters(
          products,
          null,
          [],
          [],
          ProductOption.nameAz,
          false,
        );
        emit(
          ProductLoaded(
            products,
            filtered,
            categoryId,
            [],
            [],
            true,
            ProductOption.nameAz,
            false,
            false,
          ),
        );
      },
    );
  }

  void changeSortOption(ProductOption sortOption) {
    final currentState = state;

    if (currentState is ProductLoaded) {
      final filtered = _applyFilters(
        currentState.products,
        currentState.selectedCategoryId,
        currentState.selectedClassification,
        currentState.selectedStatus,
        sortOption,
        currentState.isShowingOutOfStock,
      );

      emit(
        currentState.copyWith(
          filteredProducts: filtered,
          sortOption: sortOption,
        ),
      );
    }
  }

  void searchProducts(String query) {
    final currentState = state;

    if (currentState is ProductLoaded) {
      final searched = currentState.products.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase());
      }).toList();

      final filtered = _applyFilters(
        searched,
        currentState.selectedCategoryId,
        currentState.selectedClassification,
        currentState.selectedStatus,
        currentState.sortOption,
        currentState.isShowingOutOfStock,
      );
      emit(currentState.copyWith(filteredProducts: filtered));
    }
  }

  Future<void> loadOutOfStockProducts() async {
    emit(ProductLoading(categoryId: null, isShowingOutOfStock: true));
    final result = await _getOutOfStockProduct();
    result.fold((failure) => emit(ProductError(failure.message)), (products) {
      final filtered = _applyFilters(
        products,
        null,
        [],
        [ProductStatus.outOfStock],
        ProductOption.nameAz,
        true,
      );
      emit(
        ProductLoaded(
          products,
          filtered,
          null,
          [],
          [ProductStatus.outOfStock],
          false,
          ProductOption.nameAz,
          true,
          false,
        ),
      );
    });
  }

  Future<void> loadArchiveProducts() async {
    emit(ProductLoading(categoryId: null, isShowingOutOfStock: false));
    final result = await _getAllProducts();
    result.fold((failure) => emit(ProductError(failure.message)), (products) {
      final filtered = _applyFilters(
        products,
        null,
        [],
        [ProductStatus.reserved],
        ProductOption.nameAz,
        false,
      );
      emit(
        ProductLoaded(
          products,
          filtered,
          null,
          [],
          [ProductStatus.reserved],
          false,
          ProductOption.nameAz,
          false,
          true,
        ),
      );
    });
  }

  List<Product> _applyFilters(
    List<Product> products,
    int? categoryId,
    List<String> classifications,
    List<ProductStatus> statuses,
    ProductOption sortOption,
    bool isShowingOutOfStock,
  ) {
    var sortList = [...products];

    if (classifications.isNotEmpty) {
      sortList = sortList
          .where(
            (p) =>
                p.classification != null &&
                classifications.contains(p.classification),
          )
          .toList();
    }

    if (statuses.isNotEmpty) {
      sortList = sortList.where((p) => statuses.contains(p.status)).toList();
    } else if (!isShowingOutOfStock) {
      sortList = sortList
          .where(
            (p) =>
                p.status != ProductStatus.outOfStock &&
                p.status != ProductStatus.reserved,
          )
          .toList();
    }

    switch (sortOption) {
      case ProductOption.nameAz:
        sortList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductOption.nameZa:
        sortList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductOption.statusAvailable:
        sortList.sort(
          (a, b) => (a.status == ProductStatus.available ? 0 : 1).compareTo(
            (b.status == ProductStatus.available ? 0 : 1),
          ),
        );
        break;
      case ProductOption.statusReserved:
        sortList.sort(
          (a, b) => (a.status == ProductStatus.reserved ? 0 : 1).compareTo(
            (b.status == ProductStatus.reserved ? 0 : 1),
          ),
        );
        break;
      case ProductOption.statusOutOfStock:
        sortList.sort(
          (a, b) => (a.status == ProductStatus.outOfStock ? 0 : 1).compareTo(
            (b.status == ProductStatus.outOfStock ? 0 : 1),
          ),
        );
        break;
    }

    return sortList;
  }

  void filterByStatus(List<ProductStatus> statusList) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      final filtered = _applyFilters(
        currentState.products,
        currentState.selectedCategoryId,
        currentState.selectedClassification,
        statusList,
        currentState.sortOption,
        currentState.isShowingOutOfStock,
      );
      emit(
        currentState.copyWith(
          filteredProducts: filtered,
          selectedStatus: statusList,
        ),
      );
    }
  }

  void filterByClassification(List<String> classifications) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      final filtered = _applyFilters(
        currentState.products,
        currentState.selectedCategoryId,
        classifications,
        currentState.selectedStatus,
        currentState.sortOption,
        currentState.isShowingOutOfStock,
      );
      emit(
        currentState.copyWith(
          filteredProducts: filtered,
          selectedClassification: classifications,
        ),
      );
    }
  }

  Future<void> addProduct(Product product) async {
    final result = await _addProduct(product);
    result.fold((failure) => emit(ProductError(failure.message)), (_) {
      emit(const ProductActionSucces('Producto agregado correctamente'));
      loadProducts();
    });
  }

  Future<void> updateProduct(Product product) async {
    final result = await _upgrateProduct(product);
    result.fold((failure) => emit(ProductError(failure.message)), (_) {
      final previousState = state;
      emit(const ProductActionSucces('Producto actualizado correctamente'));
      _reloadCurrentList(previousState);
    });
  }

  Future<void> archiveProduct(int id) async {
    final result = await _archiveProduct(id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => _reloadCurrentList(),
    );
  }

  Future<void> deleteProduct(int id) async {
    final result = await _deleteProduct(id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => _reloadCurrentList(),
    );
  }

  Future<void> markAsOutOfStock(Product product) async {
    await changeProductStatus(product, ProductStatus.outOfStock);
  }

  Future<void> changeProductStatus(
    Product product,
    ProductStatus newStatus,
  ) async {
    await updateProduct(product.copyWith(status: newStatus));
  }

  Future<String?> uploadProductImage(Uint8List bytes, String fileName) async {
    final result = await _uploadProductImage(bytes, fileName);
    return result.fold((failure) {
      emit(ProductError(failure.message));
      return null;
    }, (url) => url);
  }

  void _reloadCurrentList([ProductState? oldState]) {
    final currentState = oldState ?? state;
    if (currentState is ProductLoaded && currentState.isShowingOutOfStock) {
      loadOutOfStockProducts();
    } else if (currentState is ProductLoaded &&
        currentState.isShowingReserved) {
      loadArchiveProducts();
    } else {
      loadProducts();
    }
  }
}
