import 'package:echo_stock/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryLoading extends CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  const CategoryLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoryMainLoaded extends CategoryState {
  final List<Category> categories;
  const CategoryMainLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategorySubLoaded extends CategoryState {
  final List<Category> categories;
  const CategorySubLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoryActionLoading extends CategoryState {
  final List<Category> categories;
  const CategoryActionLoading(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}

class CategoryDetailLoaded extends CategoryState {
  final Category category;
  const CategoryDetailLoaded(this.category);
  @override
  List<Object> get props => [category];
}
