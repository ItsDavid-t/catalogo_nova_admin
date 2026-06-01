import 'package:echo_stock/data/repositories/auth_repository_impl.dart';
import 'package:echo_stock/data/repositories/category_repository_impl.dart';
import 'package:echo_stock/data/repositories/product_repository_impl.dart';
import 'package:echo_stock/data/repositories/sale_repository_impl.dart';
import 'package:echo_stock/data/repositories/shop_profile_repository_impl.dart';
import 'package:echo_stock/domain/repositories/auth_repository.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:echo_stock/domain/repositories/sale_repository.dart';
import 'package:echo_stock/domain/repositories/shop_profile_repository.dart';
import 'package:echo_stock/domain/usecases/auth/get_current_session.dart';
import 'package:echo_stock/domain/usecases/auth/sign_in.dart';
import 'package:echo_stock/domain/usecases/auth/sign_out.dart';
import 'package:echo_stock/domain/usecases/auth/sign_up.dart';
import 'package:echo_stock/domain/usecases/auth/watch_auth_session.dart';
import 'package:echo_stock/domain/usecases/category/add_category.dart';
import 'package:echo_stock/domain/usecases/category/ensure_sub_category.dart';
import 'package:echo_stock/domain/usecases/category/get_all_categories.dart';
import 'package:echo_stock/domain/usecases/category/get_category_by_id.dart';
import 'package:echo_stock/domain/usecases/category/get_main_categories.dart';
import 'package:echo_stock/domain/usecases/category/get_subcategories.dart';
import 'package:echo_stock/domain/usecases/product/add_product.dart';
import 'package:echo_stock/domain/usecases/product/archive_product.dart';
import 'package:echo_stock/domain/usecases/product/delete_product.dart';
import 'package:echo_stock/domain/usecases/product/get_all_products.dart';
import 'package:echo_stock/domain/usecases/product/get_out_of_stock_product.dart';
import 'package:echo_stock/domain/usecases/product/get_products_by_categories.dart';
import 'package:echo_stock/domain/usecases/product/upload_product_image.dart';
import 'package:echo_stock/domain/usecases/product/upgrate_product.dart';
import 'package:echo_stock/domain/usecases/sale/create_sale.dart';
import 'package:echo_stock/domain/usecases/sale/get_sales_by_shop.dart';
import 'package:echo_stock/domain/usecases/shop_profile/get_shop_profile.dart';
import 'package:echo_stock/domain/usecases/shop_profile/upsert_shop_profile.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_cubit.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => Supabase.instance.client);

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ShopProfileRepository>(
    () => ShopProfileRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<SaleRepository>(() => SaleRepositoryImpl(sl()));

  sl.registerFactory(() => SignIn(sl()));
  sl.registerFactory(() => SignUp(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => GetCurrentSession(sl()));
  sl.registerFactory(() => WatchAuthSession(sl()));

  sl.registerFactory(() => GetShopProfile(sl()));
  sl.registerFactory(() => UpsertShopProfile(sl()));
  sl.registerFactory(() => GetSalesByShop(sl()));
  sl.registerFactory(() => CreateSale(sl()));

  sl.registerFactory(() => AddProduct(sl()));

  sl.registerFactory(() => GetAllProducts(sl()));

  sl.registerFactory(() => UpgrateProduct(sl()));

  sl.registerFactory(() => GetProductsByCategories(sl()));

  sl.registerFactory(() => GetOutOfStockProduct(sl()));

  sl.registerFactory(() => UploadProductImage(sl()));

  sl.registerFactory(() => DeleteProduct(sl()));

  sl.registerFactory(() => ArchiveProduct(sl()));

  sl.registerFactory(() => GetAllCategories(sl()));

  sl.registerFactory(() => GetCategoryById(sl()));

  sl.registerFactory(() => AddCategory(sl()));

  sl.registerFactory(() => GetMainCategories(sl()));

  sl.registerFactory(() => GetSubCategories(sl()));

  sl.registerFactory(() => EnsureSubCategory(sl()));

  sl.registerFactory(
    () => ShopProfileCubit(sl<GetShopProfile>(), sl<UpsertShopProfile>()),
  );

  sl.registerFactory(() => SaleCubit(sl<GetSalesByShop>(), sl<CreateSale>()));

  sl.registerLazySingleton(() => AuthCubit(sl(), sl(), sl(), sl(), sl()));

  sl.registerFactory(
    () => ProductCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  sl.registerFactory(() => CategoryCubit(sl(), sl(), sl(), sl(), sl(), sl()));
}
