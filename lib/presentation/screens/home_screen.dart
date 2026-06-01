import 'package:echo_stock/presentation/core/ui_feedback.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_state.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_cubit.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_state.dart';
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
import 'package:echo_stock/presentation/screens/account_edit_screen.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
    controllerTiltle.dispose();
    focus.dispose();
  }

  void _removeProduct(Product product) {
    ScaffoldMessenger.of(context).clearSnackBars();
    context.read<ProductCubit>().archiveProduct(product.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto eliminado'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            context.read<ProductCubit>().changeProductStatus(
              product,
              ProductStatus.available,
            );
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

  Future<void> _refreshContent() async {
    await Future.wait([
      context.read<ProductCubit>().loadProducts(),
      context.read<CategoryCubit>().fetchMainCategories(),
    ]);
  }

  Widget _buildProductContent(BuildContext context, ProductState state) {
    if (state is ProductLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const ProductListSkeleton(),
          ),
        ],
      );
    }

    if (state is ProductLoaded) {
      if (state.products.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const EmptyState(),
            ),
          ],
        );
      }

      return ProductListView(
        products: state.filteredProducts,
        onRemoveProduct: _removeProduct,
        onTapProduct: (product) async {
          final resultDialog = await showDialog(
            context: context,
            builder: (context) => ProductDetailOverlay(product: product),
          );
          if (!mounted) return;
          if (resultDialog == 'edit') {
            await _navigatorToEditProduct(product);
          }
        },
        onLongPressProduct: _navigatorToEditProduct,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const SizedBox.shrink(),
        ),
      ],
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountEditScreen(),
                ),
              );
            },
            icon: Icon(Icons.account_circle_outlined),
            tooltip: 'Editar cuenta',
          ),
        ],
        title: SizedBox(
          height: kToolbarHeight,
          width: double.infinity,
          child: BlocBuilder<ShopProfileCubit, ShopProfileState>(
            builder: (context, shopProfileState) {
              String shopName = 'Catálogo Admin';
              if (shopProfileState is ShopProfileLoaded) {
                shopName = shopProfileState.profile.shopName;
              }

              return CustomSearchBar(
                isTitle: isTitle,
                onCancel: () => context.read<ProductCubit>().searchProducts(''),
                onChanged: (value) =>
                    context.read<ProductCubit>().searchProducts(value),
                focus: focus,
                controllerTiltle: controllerTiltle,
                title: shopName,
                borderColor: Theme.of(context).colorScheme.primary,
              );
            },
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
          if (productState is ProductLoaded) {
            idSelected = productState.selectedCategoryId;
          } else if (productState is ProductLoading) {
            idSelected = productState.categoryId;
          }
          return Column(
            children: [
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, categoryState) {
                  if (categoryState is CategoryLoading) {
                    return const CategoryListSkeleton();
                  }
                  if (categoryState is CategoryError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: buildInlineErrorBanner(
                        message: categoryState.message,
                        onRetry: () =>
                            context.read<CategoryCubit>().fetchMainCategories(),
                      ),
                    );
                  }

                  if (categoryState is CategoryInitial) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (categoryState is CategoryMainLoaded) {
                    if (categoryState.categories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No hay categorías principales configuradas.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Para usar el filtrado por categorías, agrega primero una familia de categorías desde el formulario de producto.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return CategoryList(
                      categories: categoryState.categories,
                      selectedCategoryId: idSelected,
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
                      return RefreshIndicator(
                        onRefresh: _refreshContent,
                        child: _buildProductContent(context, state),
                      );
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
