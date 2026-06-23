import 'dart:developer' as developer;

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/entities/sale_item.dart';
import 'package:echo_stock/domain/repositories/sale_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SupabaseClient _supabase;

  SaleRepositoryImpl(this._supabase);

  /// consultas sql
  static const _saleSelectWithCost =
      '*, sale_item(id, sale_id, product_id, quantity, price_at_sale, cost_at_sale)';

  ///Selecciono la venta por el id
  Future<Map<String, dynamic>> _selectSaleById(int saleId) async {
    return _supabase
        .from('sale')
        .select(_saleSelectWithCost)
        .eq('id', saleId)
        .single();
  }

  /// Inserto los items de la venta
  Future<void> _insertSaleItems(int saleId, List<SaleItem> items) async {
    final payloadBasic = items
        .map(
          (item) => {
            'sale_id': saleId,
            'product_id': item.productId,
            'quantity': item.quantity,
            'price_at_sale': item.priceAtSale,
          },
        )
        .toList();
    await _supabase.from('sale_item').insert(payloadBasic);
  }

  /// Para obtener cada venta de una tienda en específico
  @override
  Future<Either<Failure, List<Sale>>> getSalesByShop(String shopId) async {
    try {
      final response = await _supabase
          .from('sale')
          .select(_saleSelectWithCost)
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      final sales = (response).map((row) => Sale.fromMap(row)).toList();
      return Right(sales);
    } catch (e, st) {
      developer.log('ERROR DE SUPABASE (sale)', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  /// Para crear una venta
  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    if (sale.items.isEmpty) {
      return Left(ValidationFailure('La venta debe tener al menos un ítem'));
    }
    try {
      final saleData = sale.toHeaderMap()..remove('id');
      final inserted = await _supabase
          .from('sale')
          .insert(saleData)
          .select()
          .single();
      final saleId = inserted['id'] as int;

      await _insertSaleItems(saleId, sale.items);

      final loaded = await _selectSaleById(saleId);

      return Right(Sale.fromMap(loaded));
    } catch (e, st) {
      developer.log('ERROR DE SUPABASE (sale)', error: e, stackTrace: st);
      return Left(DatabaseFailure('Error al registrar la venta'));
    }
  }
}
