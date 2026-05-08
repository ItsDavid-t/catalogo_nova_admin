import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_state.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:echo_stock/presentation/widgets/category_list.dart';
import 'package:echo_stock/presentation/widgets/category_list_skeleton.dart';
import 'package:echo_stock/presentation/widgets/custom_drawer.dart';
import 'package:echo_stock/presentation/widgets/custom_search_bar.dart';
import 'package:echo_stock/presentation/widgets/product_card.dart';
import 'package:echo_stock/presentation/widgets/product_filtrer_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  bool isTitle = true;
  final TextEditingController controllerTiltle = TextEditingController();
  final FocusNode focus = FocusNode();
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadOutOfStockProducts();
    context.read<CategoryCubit>().fetchMainCategories();
  }

  @override
  void dispose() {
    super.dispose();
    controllerTiltle.dispose();
    focus.dispose();
  }

  void _removeProduct(int id) {
    context.read<ProductCubit>().deleteProduct(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto eliminado'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _restoreProduct(Product product) {
    context.read<ProductCubit>().changeProductStatus(
      product,
      ProductStatus.available,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto restaurado'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade700,
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
                ? Icon(Icons.search_outlined, color: Colors.white)
                : Icon(Icons.search_off_outlined, color: Colors.white),
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
            icon: Icon(Icons.tune_outlined, color: Colors.white),
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
            title: 'Papelera de Reciclaje',
            backgroundColor: Colors.blueGrey.shade700,
            borderColor: const Color.fromARGB(255, 74, 64, 255),
          ),
        ),
        elevation: 0,
      ),
      drawer: CustomDrawer(
        onRefresh: () => context.read<ProductCubit>().loadOutOfStockProducts(),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, productState) {
          int? idSelected;
          if (productState is ProductLoaded) {
            idSelected = productState.selectedCategoryId;
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
                      categories: categoryState.categories,
                      selectedCategoryId: idSelected,
                      onCategorySelected: (category) {
                        if (category.id == idSelected) {
                          context.read<ProductCubit>().loadOutOfStockProducts();
                        } else {
                          context.read<ProductCubit>().loadProductsByCategories(
                            category.id,
                          );
                          context.read<ProductCubit>().filterByStatus([
                            ProductStatus.outOfStock,
                          ]);
                        }
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
              Expanded(
                child: BlocConsumer<ProductCubit, ProductState>(
                  listener: (context, state) {
                    if (state is ProductError) {
                      _showErrorSnackBar(state.message);
                    }
                  },
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state is ProductLoaded) {
                      if (state.filteredProducts.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildProductList(state.filteredProducts);
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.recycling_outlined, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No hay productos en la papelera',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      key: const ValueKey('recycle_list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(products[index].id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _removeProduct(products[index].id!),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.5,
                  child: ProductCard(
                    product: products[index],
                    onReadonly: true,
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 23,
                  child: IconButton(
                    onPressed: () {
                      _restoreProduct(products[index]);
                    },
                    icon: Icon(
                      Icons.replay_circle_filled,
                      color: Colors.blueAccent,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
