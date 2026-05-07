import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/usecases/category/add_category.dart';
import 'package:echo_stock/domain/usecases/category/ensure_sub_category.dart';
import 'package:echo_stock/domain/usecases/category/get_all_categories.dart';
import 'package:echo_stock/domain/usecases/category/get_category_by_id.dart';
import 'package:echo_stock/domain/usecases/category/get_main_categories.dart';
import 'package:echo_stock/domain/usecases/category/get_subcategories.dart';
import 'package:echo_stock/presentation/cubit/category/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetAllCategories _getAllCategories;
  final AddCategory _addCategory;
  final GetCategoryById _getCategoryById;
  final GetMainCategories _getMainCategories;
  final GetSubCategories _getSubCategories;
  final EnsureSubCategory _ensureSubCategory;

  CategoryCubit(
    this._getAllCategories,
    this._addCategory,
    this._getCategoryById,
    this._getMainCategories,
    this._getSubCategories,
    this._ensureSubCategory,
  ) : super(CategoryInitial());

  Future<void> loadCategories() async {
    emit(CategoryLoading());

    final result = await _getAllCategories();

    result.fold(
      (failure) {
        emit(CategoryError(failure.message));
      },
      (categories) {
        emit(CategoryLoaded(categories));
      },
    );
  }

  Future<void> fetchMainCategories() async {
    emit(CategoryLoading());

    final result = await _getMainCategories();

    result.fold(
      (failure) {
        emit(CategoryError(failure.message));
      },
      (categories) {
        final normals = categories.where((c) => c.name != 'Otros').toList();
        final another = categories.where((c) => c.name == 'Otros').toList();
        categories.sort((a, b) => a.name.compareTo(b.name));
        List<Category> newList = [...normals, ...another];
        emit(CategoryMainLoaded(newList));
      },
    );
  }

  Future<void> fetchSubCategories(int? parentId) async {
    if (parentId == null) {
      emit(const CategorySubLoaded([]));
      return;
    }
    emit(CategoryLoading());

    final result = await _getSubCategories(parentId);

    result.fold(
      (failure) {
        emit(CategoryError(failure.message));
      },
      (categories) {
        emit(CategorySubLoaded(categories));
      },
    );
  }

  Future<void> addCategory(Category category) async {
    if (state is CategoryLoaded) {
      final currentCategories = (state as CategoryLoaded).categories;
      emit(CategoryActionLoading(currentCategories));
    }
    final result = await _addCategory(category);

    result.fold(
      (failure) {
        emit(CategoryError(failure.message));
      },
      (_) {
        loadCategories();
      },
    );
  }

  Future<int> ensureSubCategory(String name, int parentId) async {
    final result = await _ensureSubCategory(name, parentId);

    return result.fold((failure) {
      emit(CategoryError(failure.message));
      return -1;
    }, (id) => id);
  }

  Future<void> getCategoryById(int id) async {
    final result = await _getCategoryById(id);

    result.fold(
      (failure) {
        emit(CategoryError(failure.message));
      },
      (category) {
        emit(CategoryDetailLoaded(category));
      },
    );
  }

  Future<void> loadMainFamilies() async {
    emit(CategoryLoading());
    final result = await _getMainCategories();

    result.fold(
      (failure) {
        emit(CategoryError(failure.message));
      },
      (categories) {
        emit(CategoryLoaded(categories));
      },
    );
  }
}
