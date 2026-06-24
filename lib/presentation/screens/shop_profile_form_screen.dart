import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_state.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_cubit.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShopProfileFormScreen extends StatefulWidget {
  final String userId;

  const ShopProfileFormScreen({super.key, required this.userId});

  @override
  State<ShopProfileFormScreen> createState() => _ShopProfileFormScreenState();
}

class _ShopProfileFormScreenState extends State<ShopProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _telegramController = TextEditingController();
  final _logoUrlController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    _whatsappController.dispose();
    _telegramController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _saveShopProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated
        ? authState.userSession.userId
        : widget.userId;

    final profile = ShopProfile(
      id: userId,
      shopName: _shopNameController.text.trim(),
      whatsappNumber: _whatsappController.text.trim(),
      telegramUsername: _normalizeTelegram(_telegramController.text),
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
      appBar: AppBar(title: const Text('Configurar tienda')),
      body: BlocConsumer<ShopProfileCubit, ShopProfileState>(
        listener: (context, state) {
          if (state is ShopProfileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSaving = state is ShopProfileSaving;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Completa la información de tu negocio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la tienda',
                      hintText: 'Ej: Ferreteria El Tornillo',
                      border: OutlineInputBorder(),
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
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El WhatsApp es obligatorio';
                      }
                      final onlyDigits = value.replaceAll(RegExp(r'\D'), '');
                      if (onlyDigits.length < 8) {
                        return 'Ingresa un numero valido (minimo 8 digitos)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telegramController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario de Telegram (opcional)',
                      hintText: 'Ej: mitienda_oficial',
                      border: OutlineInputBorder(),
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
                        return 'Usuario invalido de Telegram';
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
                        return 'URL de logo invalida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isSaving ? null : _saveShopProfile,
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar tienda'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
