import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_state.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _classificationController = TextEditingController();
  final _imgUrlController = TextEditingController();
  Category? _selectedFamily;
  ProductStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _classificationController.text = widget.product!.classification ?? '';
      _imgUrlController.text = widget.product!.imgUrl;
      _selectedStatus = widget.product!.status;
    } else {
      _selectedStatus = ProductStatus.available;
    }
    context.read<CategoryCubit>().fetchMainCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _classificationController.dispose();
    _imgUrlController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFamily == null) {
      _showErrorSnackBar('Por favor, selecciona una Categoría');
      return;
    }
    if (_selectedStatus == null) {
      _showErrorSnackBar('Por favor, selecciona un estado');
      return;
    }
    final classificationText = _classificationController.text.trim();
    int idCategory = _selectedFamily!.id!;
    if (classificationText.isNotEmpty) {
      final finalCategoryById = await context
          .read<CategoryCubit>()
          .ensureSubCategory(classificationText, _selectedFamily!.id!);

      if (finalCategoryById != -1) {
        idCategory = finalCategoryById;
      }
    }

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      classification: classificationText.isEmpty ? null : classificationText,
      categoryId: idCategory,
      imgUrl: _imgUrlController.text,
      status: _selectedStatus!,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    if (widget.product == null) {
      await context.read<ProductCubit>().addProduct(product);
    } else {
      await context.read<ProductCubit>().updateProduct(product);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.product == null ? 'Agregar' : 'Actualizar';
    return BlocListener<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductError) {
          _showErrorSnackBar(state.message);
        }

        if (state is ProductActionSucces) {
          Navigator.pop(context, true);

          final message = widget.product == null ? 'agregado' : 'actualizado';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto $message correctamente')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('$message Producto'), elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSection(
                  title: 'Información básica',
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del producto',
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return const CircularProgressIndicator();
                        }
                        if (state is CategoryMainLoaded) {
                          return Column(
                            children: [
                              DropdownButtonFormField<Category>(
                                value: _selectedFamily,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.category_outlined),
                                  labelText: 'Familia de categorías',
                                ),
                                items: state.categories.map((Category category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category.name),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedFamily = newValue;
                                  });
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _classificationController,
                                decoration: const InputDecoration(
                                  labelText: 'Clasificación (opcional)',
                                  prefixIcon: Icon(Icons.category),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _imgUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Estado del producto',
                  children: [
                    DropdownButtonFormField<ProductStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: ProductStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedStatus = value),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<ProductCubit, ProductState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Guardar producto'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ...children,
      ],
    );
  }
}
