import 'package:echo_stock/domain/core/di/service_locator.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_cubit.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:echo_stock/config/theme/app_theme.dart';
import 'package:echo_stock/presentation/screens/auth_gate_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yreqcxcolrrafdkmhsoq.supabase.co',
    anonKey: 'sb_publishable_ovQyabcWMZXgZ4BHGcVYzA_2k_bxwia',
  );

  try {
    await init();
  } catch (e) {
    rethrow;
  }

  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc.runtimeType.toString() == 'ProductCubit') {
      developer.log(
        'onChange: ${bloc.runtimeType} -> $change',
        name: 'AppBlocObserver',
      );
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (bloc.runtimeType.toString() == 'ProductCubit') {
      developer.log(
        'onTransition: ${bloc.runtimeType} -> $transition',
        name: 'AppBlocObserver',
      );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthCubit>()),
        BlocProvider(create: (context) => sl<ProductCubit>()),
        BlocProvider(create: (context) => sl<CategoryCubit>()),
        BlocProvider.value(value: sl<ShopProfileCubit>()),
        BlocProvider.value(value: sl<SaleCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Catalogo Nova Admin',
        theme: AppTheme.darkTheme,
        home: const AuthGateScreen(),
      ),
    );
  }
}
