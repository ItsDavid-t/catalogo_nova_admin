import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/screens/home_screen.dart';
import 'package:echo_stock/presentation/screens/recycle_bin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onRefresh;
  const CustomDrawer({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Image.asset('assets/images/image1.png', fit: BoxFit.cover),
          ),
          ListTile(
            leading: Icon(
              Icons.inventory,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text("Lista de productos"),
            onTap: () {
              context.read<ProductCubit>().loadProducts();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text("Papelera de reciclaje"),
            onTap: () {
              context.read<ProductCubit>().loadOutOfStockProducts();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecycleBinScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
    );
  }
}
