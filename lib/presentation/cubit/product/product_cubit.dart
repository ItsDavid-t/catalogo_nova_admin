import 'dart:typed_data';

import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/usecases/product/add_product.dart';
import 'package:echo_stock/domain/usecases/product/archive_product.dart';
import 'package:echo_stock/domain/usecases/product/delete_product.dart';
import 'package:echo_stock/domain/usecases/product/get_all_products.dart';
import 'package:echo_stock/domain/usecases/product/get_products_by_categories.dart';
import 'package:echo_stock/domain/usecases/product/upload_product_image.dart';
import 'package:echo_stock/domain/usecases/product/upgrate_product.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetAllProducts _getAllProducts;
  final AddProduct _addProduct;
  final UpgrateProduct _upgrateProduct;
  final UploadProductImage _uploadProductImage;
  final DeleteProduct _deleteProduct;
  final GetProductsByCategories _getProductsByCategories;
  final ArchiveProduct _archiveProduct;

  String? _shopId;

  ProductCubit(
    this._getAllProducts,
    this._addProduct,
    this._upgrateProduct,
    this._uploadProductImage,
    this._deleteProduct,
    this._getProductsByCategories,
    this._archiveProduct,
  ) : super(ProductInitial());

  void reset() {
    emit(ProductInitial());
  }

  Future<void> loadProducts({String? shopId}) async {
    if (shopId != null) {
      _shopId = shopId;
    }

    emit(ProductLoading(categoryId: null, isShowingOutOfStock: false));

    final result = await _getAllProducts(shopId: _shopId);

    result.fold((failure) => emit(ProductError(failure.message)), (products) {
      final filtered = _applyFilters(
        products,
        null,
        [],
        [],
        ProductOption.nameAz,
        false,
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
        currentState.isLowStockFilter,
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
        currentState.isLowStockFilter,
      );
      emit(currentState.copyWith(filteredProducts: filtered));
    }
  }

  Future<void> loadOutOfStockProducts() async {
    emit(ProductLoading(categoryId: null, isShowingOutOfStock: true));
    final result = await _getAllProducts(shopId: _shopId);
    result.fold((failure) => emit(ProductError(failure.message)), (products) {
      final outOfStockProducts = products
          .where((product) => product.isEffectivelyOutOfStock)
          .toList();
      final filtered = _applyFilters(
        outOfStockProducts,
        null,
        [],
        [ProductStatus.outOfStock],
        ProductOption.nameAz,
        true,
        false,
      );
      emit(
        ProductLoaded(
          outOfStockProducts,
          filtered,
          null,
          [],
          [ProductStatus.outOfStock],
          false,
          ProductOption.nameAz,
          true,
          false,
          false,
        ),
      );
    });
  }

  Future<void> loadArchiveProducts() async {
    emit(ProductLoading(categoryId: null, isShowingOutOfStock: false));
    final result = await _getAllProducts(shopId: _shopId);
    result.fold((failure) => emit(ProductError(failure.message)), (products) {
      final archived = products
          .where((product) => product.status == ProductStatus.reserved)
          .toList();
      final filtered = _applyFilters(
        archived,
        null,
        [],
        [ProductStatus.reserved],
        ProductOption.nameAz,
        false,
        false,
      );
      emit(
        ProductLoaded(
          archived,
          filtered,
          null,
          [],
          [ProductStatus.reserved],
          false,
          ProductOption.nameAz,
          false,
          true,
          false,
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
    bool lowStock,
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
      sortList = sortList
          .where(
            (p) =>
                statuses.contains(p.status) ||
                (statuses.contains(ProductStatus.outOfStock) &&
                    p.isEffectivelyOutOfStock),
          )
          .toList();
    } else if (!isShowingOutOfStock) {
      sortList = sortList
          .where(
            (p) =>
                p.status != ProductStatus.outOfStock &&
                p.status != ProductStatus.reserved &&
                !p.isEffectivelyOutOfStock,
          )
          .toList();
    }

    if (lowStock) {
      sortList = sortList.where((p) => p.isLowStock).toList();
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
          (a, b) => (a.isEffectivelyOutOfStock ? 0 : 1).compareTo(
            (b.isEffectivelyOutOfStock ? 0 : 1),
          ),
        );
        break;
      case ProductOption.stockLow:
        sortList.sort((a, b) => a.stock.compareTo(b.stock));
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
        currentState.isLowStockFilter,
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
        currentState.isLowStockFilter,
      );
      emit(
        currentState.copyWith(
          filteredProducts: filtered,
          selectedClassification: classifications,
        ),
      );
    }
  }

  void toggleLowStockFilter(ProductOption sortOption) {
    final currentState = state;

    if (currentState is ProductLoaded) {
      final newValue = !currentState.isLowStockFilter;
      final effectiveSortOption = newValue
          ? sortOption
          : currentState.sortOption == ProductOption.stockLow
          ? ProductOption.nameAz
          : currentState.sortOption;

      final filtered = _applyFilters(
        currentState.products,
        currentState.selectedCategoryId,
        currentState.selectedClassification,
        currentState.selectedStatus,
        effectiveSortOption,
        currentState.isShowingOutOfStock,
        newValue,
      );

      emit(
        currentState.copyWith(
          isLowStockFilter: newValue,
          filteredProducts: filtered,
          sortOption: effectiveSortOption,
        ),
      );
    }
  }

  Future<void> addProduct(Product product) async {
    final syncedProduct = product.normalize();
    final result = await _addProduct(syncedProduct);
    result.fold((failure) => emit(ProductError(failure.message)), (_) {
      emit(const ProductActionSucces('Producto agregado correctamente'));
      loadProducts();
    });
  }

  Future<void> updateProduct(Product product) async {
    final syncedProduct = product.normalize();
    final result = await _upgrateProduct(syncedProduct);
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
    await updateProduct(
      product.copyWith(stock: 0, status: ProductStatus.outOfStock),
    );
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
