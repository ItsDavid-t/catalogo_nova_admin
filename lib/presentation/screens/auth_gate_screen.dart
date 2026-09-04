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
import 'package:echo_stock/domain/core/di/service_locator.dart';
import 'package:echo_stock/domain/usecases/invite/list_invite_codes.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  String? _loadedShopId;
  String? _catalogLoadedForShopId;

  void _loadShopProfile(String shopId) {
    if (_loadedShopId == shopId) return;
    _loadedShopId = shopId;
    _catalogLoadedForShopId = null;
    context.read<ShopProfileCubit>().loadProfile(shopId);
  }

  void _loadCatalogData(String shopId) {
    if (_catalogLoadedForShopId == shopId) return;
    _catalogLoadedForShopId = shopId;
    context.read<ProductCubit>().loadProducts(shopId: shopId);
    context.read<CategoryCubit>().fetchMainCategories(shopId: shopId);
  }

  void _resetCatalogData() {
    context.read<ProductCubit>().reset();
    context.read<CategoryCubit>().reset();
  }

  @override
  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🟢 AUTHGATE INSTANCE: ${identityHashCode(context.read<AuthCubit>())}',
    );

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthAuthenticated ||
          current is AuthUnauthenticated ||
          current is AuthFailure,
      listener: (context, state) {
        debugPrint(
          '🟢 AuthGate AuthCubit INSTANCE: ${identityHashCode(context.read<AuthCubit>())}',
        );

        debugPrint('🟢 AuthGate listener: $state');

        if (state is AuthAuthenticated) {
          _loadShopProfile(state.userSession.shopId);
          return;
        }

        if (state is AuthUnauthenticated || state is AuthFailure) {
          _loadedShopId = null;
          _catalogLoadedForShopId = null;
          _resetCatalogData();
          Navigator.of(context).popUntil((route) => route.isFirst);
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
            if (_loadedShopId != state.userSession.shopId) {
              _loadShopProfile(state.userSession.shopId);
            }
            return BlocConsumer<ShopProfileCubit, ShopProfileState>(
              listenWhen: (previous, current) =>
                  current is ShopProfileLoaded || current is ShopProfileSaved,
              listener: (context, shopState) {
                if (shopState is ShopProfileLoaded ||
                    shopState is ShopProfileSaved) {
                  _loadCatalogData(state.userSession.shopId);
                }
              },
              builder: (context, shopState) {
                if ((shopState is ShopProfileLoaded ||
                        shopState is ShopProfileSaved) &&
                    _catalogLoadedForShopId != state.userSession.shopId) {
                  _loadCatalogData(state.userSession.shopId);
                }

                if (shopState is ShopProfileInitial ||
                    shopState is ShopProfileLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (shopState is ShopProfileMissing) {
                  if (state.userSession.isAdmin) {
                    return ShopProfileFormScreen(userId: shopState.userId);
                  }
                  final ownerId = state.userSession.ownerId;
                  if (ownerId != null &&
                      ownerId.isNotEmpty &&
                      ownerId != shopState.userId) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadShopProfile(ownerId);
                    });

                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if ((ownerId == null || ownerId.isEmpty) &&
                      state.userSession.userId.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      try {
                        final listInvite = sl<ListInviteCodes>();
                        final result = await listInvite.call();
                        result.fold((_) {}, (codes) {
                          try {
                            final match = codes.firstWhere(
                              (c) =>
                                  c['used_by']?.toString() ==
                                      state.userSession.userId &&
                                  c['created_by'] != null &&
                                  c['created_by'].toString().isNotEmpty,
                            );
                            final inferredOwner = match['created_by']
                                ?.toString();
                            if (inferredOwner != null &&
                                inferredOwner.isNotEmpty &&
                                inferredOwner != _loadedShopId) {
                              _loadShopProfile(inferredOwner);
                            }
                          } catch (_) {}
                        });
                      } catch (_) {}
                    });

                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Scaffold(
                    appBar: AppBar(title: const Text('Acceso denegado')),
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'No tienes permiso para crear el perfil de tienda. Contacta al administrador.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (shopState is ShopProfileLoaded ||
                    shopState is ShopProfileSaved) {
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
                              onPressed: () =>
                                  _loadShopProfile(state.userSession.shopId),
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
