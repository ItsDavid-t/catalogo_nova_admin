import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_state.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_cubit.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_state.dart';
import 'package:echo_stock/presentation/screens/home_screen.dart';
import 'package:echo_stock/presentation/screens/login_screen.dart';
import 'package:echo_stock/presentation/screens/shop_profile_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  String? _loadedUserId;
  String? _catalogLoadedForUserId;

  void _loadShopProfile(String userId) {
    if (_loadedUserId == userId) return;
    _loadedUserId = userId;
    _catalogLoadedForUserId = null;
    context.read<ShopProfileCubit>().loadProfile(userId);
  }

  void _loadCatalogData(String userId) {
    if (_catalogLoadedForUserId == userId) return;
    _catalogLoadedForUserId = userId;
    context.read<ProductCubit>().loadProducts();
    context.read<CategoryCubit>().fetchMainCategories();
  }

  void _resetCatalogData() {
    context.read<ProductCubit>().reset();
    context.read<CategoryCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthAuthenticated ||
          current is AuthUnauthenticated ||
          current is AuthFailure,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _loadShopProfile(state.userSession.uuid);
          return;
        }

        if (state is AuthUnauthenticated || state is AuthFailure) {
          _loadedUserId = null;
          _catalogLoadedForUserId = null;
          _resetCatalogData();
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AuthAuthenticated) {
            _loadShopProfile(state.userSession.uuid);
            return BlocConsumer<ShopProfileCubit, ShopProfileState>(
              listenWhen: (previous, current) =>
                  current is ShopProfileLoaded || current is ShopProfileSaved,
              listener: (context, shopState) {
                if (shopState is ShopProfileLoaded ||
                    shopState is ShopProfileSaved) {
                  _loadCatalogData(state.userSession.uuid);
                }
              },
              builder: (context, shopState) {
                if (shopState is ShopProfileInitial ||
                    shopState is ShopProfileLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (shopState is ShopProfileMissing) {
                  return ShopProfileFormScreen(userId: shopState.userId);
                }

                if (shopState is ShopProfileLoaded ||
                    shopState is ShopProfileSaved) {
                  _loadCatalogData(state.userSession.uuid);
                  return const HomeScreen();
                }

                if (shopState is ShopProfileFailure) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Error al cargar el perfil: ${shopState.message}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => _loadShopProfile(
                                state.userSession.uuid,
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
