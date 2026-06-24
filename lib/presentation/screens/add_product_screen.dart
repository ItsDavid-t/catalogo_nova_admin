import 'dart:typed_data';

import 'package:echo_stock/domain/entities/category.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_cubit.dart';
import 'package:echo_stock/presentation/cubit/category/category_state.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:file_selector/file_selector.dart';
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
  final _newCategoryController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockAlertController = TextEditingController();
  Category? _selectedFamily;
  ProductStatus? _selectedStatus;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _classificationController.text = widget.product!.classification ?? '';
      _imgUrlController.text = widget.product!.imgUrl;
      _costPriceController.text = widget.product!.costPrice.toString();
      _sellPriceController.text = widget.product!.sellPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      _lowStockAlertController.text = widget.product!.lowStockAlert.toString();
      _selectedStatus = widget.product!.status;
    } else {
      _selectedStatus = ProductStatus.available;
      _costPriceController.text = '0.0';
      _sellPriceController.text = '0.0';
      _stockController.text = '0';
      _lowStockAlertController.text = '0';
    }
    final currentUserId = context.read<AuthCubit>().currentSession?.userId;
    context.read<CategoryCubit>().fetchMainCategories(shopId: currentUserId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _classificationController.dispose();
    _imgUrlController.dispose();
    _newCategoryController.dispose();
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _lowStockAlertController.dispose();
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

    if (_imgUrlController.text.isEmpty && _selectedImageBytes == null) {
      _showErrorSnackBar('Por favor, selecciona o ingresa una imagen');
      return;
    }

    String imgUrl = _imgUrlController.text;

    if (_selectedImageBytes != null && _selectedImageName != null) {
      final uploadedUrl = await context.read<ProductCubit>().uploadProductImage(
        _selectedImageBytes!,
        _selectedImageName!,
      );
      if (uploadedUrl == null) {
        return;
      }
      imgUrl = uploadedUrl;
    }
    final currentUserId = context.read<AuthCubit>().currentSession?.userId;

    final classificationText = _classificationController.text.trim();
    int idCategory = _selectedFamily!.id!;
    if (classificationText.isNotEmpty) {
      final finalCategoryById = await context
          .read<CategoryCubit>()
          .ensureSubCategory(
            classificationText,
            _selectedFamily!.id!,
            currentUserId,
          );

      if (finalCategoryById != -1) {
        idCategory = finalCategoryById;
      }
    }

    final stock = int.tryParse(_stockController.text) ?? 0;
    final lowStockAlert = int.tryParse(_lowStockAlertController.text) ?? 0;
    var status = _selectedStatus!;
    if (stock <= 0) {
      status = ProductStatus.outOfStock;
    }

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      classification: classificationText.isEmpty ? null : classificationText,
      categoryId: idCategory,
      stock: stock,
      lowStockAlert: lowStockAlert,
      costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
      sellPrice: double.tryParse(_sellPriceController.text) ?? 0.0,
      imgUrl: imgUrl,
      status: status,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      shopId: currentUserId,
    );

    if (widget.product == null) {
      await context.read<ProductCubit>().addProduct(product);
    } else {
      await context.read<ProductCubit>().updateProduct(product);
    }
  }

  Future<void> _pickImage() async {
    final result = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg', 'gif']),
      ],
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = result.name;
      });
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

  Future<void> _showAddCategoryDialog() async {
    _newCategoryController.clear();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar categoría'),
          content: TextField(
            controller: _newCategoryController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
              hintText: 'Ej. Herramientas',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newCategoryController.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (created != true) return;

    final currentUserId = context.read<AuthCubit>().currentSession?.userId;
    final newCategoryName = _newCategoryController.text.trim();
    await context.read<CategoryCubit>().addCategory(
      Category(name: newCategoryName, shopId: currentUserId),
    );
    await context.read<CategoryCubit>().fetchMainCategories(
      shopId: currentUserId,
    );
    final categoryState = context.read<CategoryCubit>().state;
    if (categoryState is CategoryMainLoaded) {
      try {
        final createdCategory = categoryState.categories.firstWhere(
          (c) => c.name == newCategoryName,
        );
        if (mounted) {
          setState(() {
            _selectedFamily = createdCategory;
          });
        }
      } catch (_) {
        return;
      }
    }
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is CategoryError) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Error cargando categorías: ${state.message}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  final currentUserId = context
                                      .read<AuthCubit>()
                                      .currentSession
                                      ?.userId;
                                  context
                                      .read<CategoryCubit>()
                                      .fetchMainCategories(
                                        shopId: currentUserId,
                                      );
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          );
                        }
                        if (state is CategoryMainLoaded) {
                          if (state.categories.isEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No hay familias de categorías disponibles.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agrega una categoría principal para poder asignar productos.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _showAddCategoryDialog,
                                  child: const Text('Agregar categoría'),
                                ),
                              ],
                            );
                          }

                          if (_selectedFamily == null &&
                              widget.product?.categoryId != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final match = state.categories.firstWhere(
                                (category) =>
                                    category.id == widget.product!.categoryId,
                                orElse: () => state.categories.first,
                              );

                              if (mounted && _selectedFamily == null) {
                                setState(() {
                                  _selectedFamily = match;
                                });
                              }
                            });
                          }

                          return Column(
                            children: [
                              DropdownButtonFormField<Category>(
                                initialValue: _selectedFamily,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.category_outlined),
                                  labelText: 'Familia de categorías',
                                ),
                                items: state.categories.map((
                                  Category category,
                                ) {
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
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _showAddCategoryDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text(
                                    'Agregar familia de categoría',
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imgUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL de imagen',
                              prefixIcon: Icon(Icons.image_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Seleccionar'),
                        ),
                      ],
                    ),
                    if (_selectedImageName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Archivo seleccionado: $_selectedImageName',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Precios',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _costPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio de costo',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              if (double.tryParse(v) == null) {
                                return 'Debe ser un número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _sellPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio de venta',
                              prefixIcon: Icon(Icons.sell),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              if (double.tryParse(v) == null) {
                                return 'Debe ser un número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Inventario',
                  children: [
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock actual',
                        prefixIcon: Icon(Icons.layers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (int.tryParse(v) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final stock = int.tryParse(value) ?? 0;
                        if (stock <= 0 && mounted) {
                          setState(() {
                            _selectedStatus = ProductStatus.outOfStock;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _lowStockAlertController,
                      decoration: const InputDecoration(
                        labelText: 'Stock mínimo (alerta)',
                        prefixIcon: Icon(Icons.notification_important),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (int.tryParse(v) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Estado del producto',
                  children: [
                    DropdownButtonFormField<ProductStatus>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: ProductStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedStatus = value),
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
