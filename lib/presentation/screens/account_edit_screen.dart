import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_state.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_cubit.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _whatsappController;
  late TextEditingController _telegramController;
  late TextEditingController _descriptionController;
  late TextEditingController _logoUrlController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _whatsappController = TextEditingController();
    _telegramController = TextEditingController();
    _descriptionController = TextEditingController();
    _logoUrlController = TextEditingController();
    _loadShopProfile();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _whatsappController.dispose();
    _telegramController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _loadShopProfile() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ShopProfileCubit>().loadProfile(
        authState.userSession.userId,
      );
    }
  }

  void _populateForm(ShopProfile profile) {
    _shopNameController.text = profile.shopName;
    _whatsappController.text = profile.whatsappNumber;
    _telegramController.text = profile.telegramUsername ?? '';
    _descriptionController.text = profile.description ?? '';
    _logoUrlController.text = profile.logoUrl ?? '';
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    final profile = ShopProfile(
      id: authState.userSession.userId,
      shopName: _shopNameController.text.trim(),
      whatsappNumber: _whatsappController.text.trim(),
      telegramUsername: _normalizeTelegram(_telegramController.text),
      description: _normalizeOptional(_descriptionController.text),
      logoUrl: _normalizeOptional(_logoUrlController.text),
      createdAt: DateTime.now(),
    );

    context.read<ShopProfileCubit>().saveProfile(profile);
  }

  String? _normalizeOptional(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return value;
  }

  String? _normalizeTelegram(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return value.startsWith('@') ? value.substring(1) : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cuenta'), elevation: 0),
      body: BlocConsumer<ShopProfileCubit, ShopProfileState>(
        listener: (context, state) {
          if (state is ShopProfileLoaded) {
            _populateForm(state.profile);
          } else if (state is ShopProfileSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cambios guardados exitosamente')),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is ShopProfileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          final isLoading = state is ShopProfileLoading;
          final isSaving = state is ShopProfileSaving;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección Datos de la Tienda
                    Text(
                      'Información de la Tienda',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la tienda',
                        hintText: 'Ej: Ferreteria El Tornillo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre de la tienda es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp de contacto',
                        hintText: 'Ej: +5355555555',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El WhatsApp es obligatorio';
                        }
                        final onlyDigits = value.replaceAll(RegExp(r'\D'), '');
                        if (onlyDigits.length < 8) {
                          return 'Ingresa un número válido (mínimo 8 dígitos)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción de la tienda (opcional)',
                        hintText: 'Cuéntanos sobre tu tienda...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sección Redes Sociales
                    Text(
                      'Redes Sociales',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telegramController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario de Telegram (opcional)',
                        hintText: 'Ej: mitienda_oficial',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.chat),
                      ),
                      validator: (value) {
                        final telegram = value?.trim() ?? '';
                        if (telegram.isEmpty) return null;
                        final normalized = telegram.startsWith('@')
                            ? telegram.substring(1)
                            : telegram;
                        final isValid = RegExp(
                          r'^[a-zA-Z0-9_]{5,}$',
                        ).hasMatch(normalized);
                        if (!isValid) {
                          return 'Usuario inválido de Telegram';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _logoUrlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Logo URL (opcional)',
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        final url = value?.trim() ?? '';
                        if (url.isEmpty) return null;
                        final uri = Uri.tryParse(url);
                        final isValid =
                            uri != null &&
                            (uri.scheme == 'http' || uri.scheme == 'https') &&
                            uri.host.isNotEmpty;
                        if (!isValid) {
                          return 'URL de logo inválida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: isSaving ? null : _saveProfile,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        isSaving ? 'Guardando...' : 'Guardar Cambios',
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
