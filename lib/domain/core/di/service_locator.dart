import 'package:echo_stock/data/repositories/category_repository_impl.dart';
import 'package:echo_stock/data/repositories/product_repository_impl.dart';
import 'package:echo_stock/domain/repositories/category_repository.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:echo_stock/domain/usecases/category/add_category.dart';
import 'package:echo_stock/domain/usecases/category/ensure_sub_category.dart';
import 'package:echo_stock/domain/usecases/category/get_all_categories.dart';
import 'package:echo_stock/domain/usecases/category/get_category_by_id.dart';
import 'package:echo_stock/domain/usecases/category/get_main_categories.dart';
import 'package:echo_stock/domain/usecases/category/get_subcategories.dart';
import 'package:echo_stock/domain/usecases/product/add_product.dart';
import 'package:echo_stock/domain/usecases/product/delete_product.dart';
import 'package:echo_stock/domain/usecases/product/get_all_products.dart';
import 'package:echo_stock/domain/usecases/product/get_out_of_stock_product.dart';
import 'package:echo_stock/domain/usecases/product/get_products_by_categories.dart';
import 'package:echo_stock/domain/usecases/product/upload_product_image.dart';
import 'package:echo_stock/domain/usecases/product/upgrate_product.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => Supabase.instance.client);

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerFactory(() => AddProduct(sl()));

  sl.registerFactory(() => GetAllProducts(sl()));

  sl.registerFactory(() => UpgrateProduct(sl()));

  sl.registerFactory(() => GetProductsByCategories(sl()));

  sl.registerFactory(() => GetOutOfStockProduct(sl()));

  sl.registerFactory(() => UploadProductImage(sl()));

  sl.registerFactory(() => DeleteProduct(sl()));

  sl.registerFactory(() => GetAllCategories(sl()));

  sl.registerFactory(() => GetCategoryById(sl()));

  sl.registerFactory(() => AddCategory(sl()));

  sl.registerFactory(() => GetMainCategories(sl()));

  sl.registerFactory(() => GetSubCategories(sl()));

  sl.registerFactory(() => EnsureSubCategory(sl()));

  sl.registerFactory(
    () => ProductCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  sl.registerFactory(() => CategoryCubit(sl(), sl(), sl(), sl(), sl(), sl()));
}
