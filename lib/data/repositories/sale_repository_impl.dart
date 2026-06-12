import 'dart:developer' as developer;

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/repositories/sale_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SupabaseClient _supabase;

  SaleRepositoryImpl(this._supabase);

  static const _saleSelect =
      '*, sale_item(id, sale_id, product_id, quantity, price_at_sale)';

  ///Obtengo las ventas de cada tienda(filtro por shop_id, y las ordeno por fecha de creada descendentemente)
  @override
  Future<Either<Failure, List<Sale>>> getSalesByShop(String shopId) async {
    try {
      final response = await _supabase
          .from('sale')
          .select(_saleSelect)
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      final sales = (response as List)
          .map((row) => Sale.fromMap(row as Map<String, dynamic>))
          .toList();
      return Right(sales);
    } catch (e) {
      developer.log('ERROR DE SUPABASE (sale): $e');
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  ///Para crear una nueva venta (le borro el id porq el id en mi base de datos es autoincremental)
  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    if (sale.items.isEmpty) {
      return Left(ValidationFailure('La venta debe tener al menos un ítem'));
    }
    try {
      final header = sale.toHeaderMap()..remove('id');
      final inserted = await _supabase
          .from('sale')
          .insert(header)
          .select()
          .single();
      final saleId = inserted['id'] as int;

      final itemsPayload = sale.items
          .map(
            (item) => {
              'sale_id': saleId,
              'product_id': item.productId,
              'quantity': item.quantity,
              'price_at_sale': item.priceAtSale,
            },
          )
          .toList();
      await _supabase.from('sale_item').insert(itemsPayload);

      final loaded = await _supabase
          .from('sale')
          .select(_saleSelect)
          .eq('id', saleId)
          .single();
      return Right(Sale.fromMap(loaded));
    } catch (e) {
      developer.log('ERROR DE SUPABASE (sale): $e');
      return Left(DatabaseFailure('Error al registrar la venta'));
    }
  }
}
