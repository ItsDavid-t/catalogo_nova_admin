import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_state.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:echo_stock/presentation/widgets/category_list.dart';
import 'package:echo_stock/presentation/widgets/category_list_skeleton.dart';
import 'package:echo_stock/presentation/widgets/custom_drawer.dart';
import 'package:echo_stock/presentation/widgets/custom_search_bar.dart';
import 'package:echo_stock/presentation/widgets/empty_state.dart';
import 'package:echo_stock/presentation/widgets/product_filtrer_panel.dart';
import 'package:echo_stock/presentation/widgets/product_list_view.dart';
import 'package:echo_stock/presentation/widgets/product_detail_overlay.dart';
import 'package:flutter/material.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/presentation/screens/add_product_screen.dart';
import 'package:echo_stock/presentation/widgets/product_list_skeleton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isTitle = true;
  final TextEditingController controllerTiltle = TextEditingController();
  final FocusNode focus = FocusNode();
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
    context.read<CategoryCubit>().fetchMainCategories();
  }

  @override
  void dispose() {
    super.dispose();
    controllerTiltle.dispose();
    focus.dispose();
  }

  void _removeProduct(Product product) {
    ScaffoldMessenger.of(context).clearSnackBars();
    context.read<ProductCubit>().markAsOutOfStock(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto marcado como agotado'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            context.read<ProductCubit>().updateProduct(product);
          },
          backgroundColor: Colors.blue.shade700,
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (isTitle) {
                  isTitle = false;
                  Future.delayed(Duration.zero, () => focus.requestFocus());
                } else {
                  isTitle = true;
                  controllerTiltle.clear();
                  context.read<ProductCubit>().searchProducts('');
                }
              });
            },
            icon: isTitle
                ? Icon(Icons.search_outlined)
                : Icon(Icons.search_off_outlined),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return ProductFiltrerPanel();
                },
              );
            },
            icon: Icon(Icons.tune_outlined),
          ),
        ],
        title: SizedBox(
          height: kToolbarHeight,
          width: double.infinity,
          child: CustomSearchBar(
            isTitle: isTitle,
            onCancel: () => context.read<ProductCubit>().searchProducts(''),
            onChanged: (value) =>
                context.read<ProductCubit>().searchProducts(value),
            focus: focus,
            controllerTiltle: controllerTiltle,
            title: 'Catalogo Nova Admin',
            borderColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        elevation: 0,
      ),
      drawer: CustomDrawer(
        onRefresh: () => context.read<ProductCubit>().loadProducts(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, productState) {
          int? idSelected;
          bool isLowerStock = false;
          if (productState is ProductLoaded) {
            idSelected = productState.selectedCategoryId;
            isLowerStock = productState.isShowingOutOfStock;
          } else if (productState is ProductLoading) {
            idSelected = productState.categoryId;
            isLowerStock = productState.isShowingOutOfStock;
          }
          return Column(
            children: [
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, categoryState) {
                  if (categoryState is CategoryLoading) {
                    return const CategoryListSkeleton();
                  }
                  if (categoryState is CategoryMainLoaded) {
                    return CategoryList(
                      isRecycleBin: false,
                      categories: categoryState.categories,
                      selectedCategoryId: idSelected,
                      isLowStockSelected: productState is ProductLoaded
                          ? productState.isShowingOutOfStock
                          : false,
                      onSelected: () => context
                          .read<ProductCubit>()
                          .loadOutOfStockProducts(),
                      onCategorySelected: (category) {
                        if (category.id == idSelected) {
                          context.read<ProductCubit>().loadProducts();
                        } else {
                          context.read<ProductCubit>().loadProductsByCategories(
                            category.id!,
                          );
                        }
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
              if (productState is ProductLoaded)
                Expanded(
                  child: BlocConsumer<ProductCubit, ProductState>(
                    listener: (context, state) {
                      if (state is ProductError) {
                        _showErrorSnackBar(state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const ProductListSkeleton();
                      }
                      if (state is ProductLoaded) {
                        if (state.products.isEmpty) {
                          return const EmptyState();
                        }

                        return ProductListView(
                          products: state.filteredProducts,
                          onRemoveProduct: _removeProduct,
                          onTapProduct: (product) async {
                            final resultDialog = await showDialog(
                              context: context,
                              builder: (context) =>
                                  ProductDetailOverlay(product: product),
                            );
                            if (!mounted) return;
                            if (resultDialog == 'edit') {
                              await _navigatorToEditProduct(product);
                            }
                          },
                          onLongPressProduct: _navigatorToEditProduct,
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigatorToEditProduct(Product p) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen(product: p)),
    );

    if (result == true) {
      context.read<ProductCubit>().loadProducts();
    }
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
    if (result == true) {
      context.read<ProductCubit>().loadProducts();
    }
  }
}
