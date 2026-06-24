import 'package:echo_stock/domain/entities/cart_item.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_cubit.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_state.dart';
import 'package:echo_stock/presentation/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final shopId = context.read<AuthCubit>().currentSession?.userId;
    context.read<ProductCubit>().loadProducts(shopId: shopId);
    context.read<SaleCubit>().clearCart();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _availableProducts(ProductLoaded state) {
    return state.products.where((product) {
      final hasStock = product.stock > 0 && !product.isEffectivelyOutOfStock;
      final isSellable = product.status == ProductStatus.available;
      final matchesQuery =
          _query.isEmpty ||
          product.name.toLowerCase().contains(_query.toLowerCase());
      return hasStock && isSellable && matchesQuery;
    }).toList();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmSale() async {
    final shopId = context.read<AuthCubit>().currentSession?.userId;
    if (shopId == null) {
      _showMessage('Sesión no válida', isError: true);
      return;
    }

    await context.read<SaleCubit>().confirmSale(shopId: shopId);
  }

  void _addProduct(Product product) {
    if (product.id == null) return;
    context.read<SaleCubit>().addProductToCart(CartItem.fromProduct(product));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.read<SaleCubit>().clearCart(),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Vaciar carrito',
          ),
        ],
      ),
      drawer: CustomDrawer(
        onRefresh: () {
          final shopId = context.read<AuthCubit>().currentSession?.userId;
          context.read<ProductCubit>().loadProducts(shopId: shopId);
        },
      ),
      body: BlocListener<SaleCubit, SaleState>(
        listener: (context, state) {
          if (state is SaleFailure) {
            _showMessage(state.message, isError: true);
          }
          if (state is SaleConfirmed) {
            _showMessage(state.message);
            final shopId = context.read<AuthCubit>().currentSession?.userId;
            context.read<ProductCubit>().loadProducts(shopId: shopId);
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar producto (ej. Tubo)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, productState) {
                if (productState is! ProductLoaded || _query.isEmpty) {
                  return const SizedBox.shrink();
                }

                final matches = _availableProducts(
                  productState,
                ).take(8).toList();
                if (matches.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sin coincidencias',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: matches.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final product = matches[index];
                      return ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: Text(product.name),
                        onPressed: () => _addProduct(product),
                      );
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Carrito',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SaleCubit, SaleState>(
                buildWhen: (previous, current) =>
                    current is CartUpdated ||
                    current is SaleCreating ||
                    current is SaleConfirmed ||
                    current is SaleFailure,
                builder: (context, state) {
                  final cartItems = context.read<SaleCubit>().cartItems;

                  if (cartItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 56,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 12),
                          const Text('Carrito vacío'),
                          const SizedBox(height: 4),
                          Text(
                            'Busca y toca un producto para agregarlo',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.sellPrice.toStringAsFixed(2)} c/u',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => context
                                    .read<SaleCubit>()
                                    .decrementCartItem(item.productId),
                                icon: const Icon(Icons.remove_circle),
                                iconSize: 36,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                              IconButton(
                                onPressed: () => context
                                    .read<SaleCubit>()
                                    .incrementCartItem(item.productId),
                                icon: const Icon(Icons.add_circle),
                                iconSize: 36,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${item.lineTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _CheckoutBar(onConfirm: _confirmSale),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final VoidCallback onConfirm;

  const _CheckoutBar({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleCubit, SaleState>(
      buildWhen: (previous, current) =>
          current is CartUpdated ||
          current is SaleCreating ||
          current is SaleConfirmed,
      builder: (context, state) {
        final cubit = context.read<SaleCubit>();
        final total = cubit.totalAmount;
        final hasItems = cubit.cartItems.isNotEmpty;
        final isProcessing = state is SaleCreating;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: !hasItems || isProcessing ? null : onConfirm,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 28),
                      label: Text(
                        isProcessing ? 'Procesando...' : 'Confirmar Venta',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
