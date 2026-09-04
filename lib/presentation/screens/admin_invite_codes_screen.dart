import 'dart:math';

import 'package:echo_stock/domain/core/di/service_locator.dart';
import 'package:flutter/services.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/domain/usecases/invite/create_invite_code.dart';
import 'package:echo_stock/domain/usecases/invite/list_invite_codes.dart';
import 'package:echo_stock/domain/usecases/invite/revoke_invite_code.dart';
import 'package:echo_stock/domain/usecases/invite/mark_invite_code_used.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminInviteCodesScreen extends StatefulWidget {
  const AdminInviteCodesScreen({super.key});

  @override
  State<AdminInviteCodesScreen> createState() => _AdminInviteCodesScreenState();
}

class _AdminInviteCodesScreenState extends State<AdminInviteCodesScreen> {
  final CreateInviteCode _createInvite = sl();
  final ListInviteCodes _listInvite = sl();
  final RevokeInviteCode _revokeInvite = sl();
  final MarkInviteCodeUsed _markInviteUsed = sl();

  List<Map<String, dynamic>> _codes = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCodes();
  }

  Future<void> _fetchCodes() async {
    setState(() => _loading = true);
    final result = await _listInvite.call();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar códigos: ${failure.message}'),
            ),
          );
        }
      },
      (list) {
        setState(() => _codes = list);
      },
    );
    setState(() => _loading = false);
  }

  String _rand(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(
      length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  Future<void> _createCode(String role) async {
    final adminId = context.read<AuthCubit>().currentSession?.shopId;
    final code =
        '${role.substring(0, role.length < 3 ? role.length : 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}-${_rand(4)}';

    final result = await _createInvite.call(
      code: code,
      role: role,
      createdBy: adminId,
    );
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creando código: ${failure.message}')),
          );
        }
      },
      (_) async {
        await _fetchCodes();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Código creado: $code')));
        }
      },
    );
  }

  Future<void> _markUsed(String code) async {
    final result = await _markInviteUsed.call(code);
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error marcando usado: ${failure.message}')),
          );
        }
      },
      (_) async {
        await _fetchCodes();
      },
    );
  }

  Future<void> _revokeCode(String code) async {
    final result = await _revokeInvite.call(code);
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error revocando: ${failure.message}')),
          );
        }
      },
      (_) async {
        await _fetchCodes();
      },
    );
  }

  void _onCreatePressed() {
    showDialog(
      context: context,
      builder: (context) {
        String selected = 'employee';
        return AlertDialog(
          title: const Text('Generar código'),
          content: StatefulBuilder(
            builder: (context, setSt) => DropdownButton<String>(
              value: selected,
              items: const [
                DropdownMenuItem(value: 'employee', child: Text('Empleado')),
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (v) => setSt(() => selected = v ?? 'employee'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _createCode(selected);
              },
              child: const Text('Generar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar códigos')),
      drawer: CustomDrawer(
        onRefresh: () => context.read<ProductCubit>().loadProducts(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePressed,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCodes,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _codes.length,
                itemBuilder: (context, index) {
                  final c = _codes[index];
                  final code = c['code'] as String? ?? '';
                  final role = c['role'] as String? ?? '';
                  final status = c['status'] as String? ?? '';
                  final usedBy = c['used_by']?.toString();
                  final createdAt = c['created_at']?.toString();
                  return Card(
                    child: ListTile(
                      title: Text(code),
                      subtitle: Text('Rol: $role • Estado: $status'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: code),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Código copiado'),
                                  ),
                                );
                              }
                            },
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'revoke') _revokeCode(code);
                              if (v == 'mark_used') _markUsed(code);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'mark_used',
                                child: Text('Marcar como usado'),
                              ),
                              const PopupMenuItem(
                                value: 'revoke',
                                child: Text('Revocar'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      isThreeLine: usedBy != null || createdAt != null,
                      subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
