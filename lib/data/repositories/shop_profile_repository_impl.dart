import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:io';

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/domain/repositories/shop_profile_repository.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopProfileRepositoryImpl implements ShopProfileRepository {
  final SupabaseClient _supabase;

  ShopProfileRepositoryImpl(this._supabase);

  ///Para obtener la tienda de cada usuario mediante su id
  @override
  Future<Either<Failure, ShopProfile?>> getByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('shop_profile')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response == null) {
        return const Right(null);
      }
      return Right(ShopProfile.fromMap(response));
    } catch (e) {
      developer.log('ERROR DE SUPABASE (shop_profile): $e');
      return Left(DatabaseFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsert(ShopProfile profile) async {
    try {
      final data = profile.toMap();
      await _supabase.from('shop_profile').upsert(data);
      return Right(unit);
    } catch (e) {
      developer.log('ERROR DE SUPABASE (shop_profile): $e');
      return Left(DatabaseFailure('Error al guardar el perfil de tienda'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadLogo(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final path =
          'shop-profile/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final storage = _supabase.storage.from('product-images');
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: false),
      );
      final publicUrl = storage.getPublicUrl(path);
      return Right(publicUrl);
    } catch (e) {
      developer.log('ERROR DE SUPABASE STORAGE (shop_profile): $e');
      return Left(DatabaseFailure('Error al subir el logo de la tienda'));
    }
  }

  @override
  Future<Either<Failure, String?>> exportProfileData(
    ShopProfile profile,
  ) async {
    try {
      final suggestedName =
          '${profile.shopName.replaceAll(RegExp(r"[^A-Za-z0-9_]"), '_')}_perfil.json';
      final payload = {
        'exported_at': DateTime.now().toIso8601String(),
        'profile': profile.toMap(),
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      final bytes = Uint8List.fromList(jsonString.codeUnits);
      final exportFile = XFile.fromData(
        bytes,
        mimeType: 'application/json',
        name: suggestedName,
      );

      try {
        final saveLocation = await getSaveLocation(
          acceptedTypeGroups: [
            XTypeGroup(label: 'JSON', extensions: ['json']),
          ],
          suggestedName: suggestedName,
        );

        if (saveLocation == null) {
          return const Right(null);
        }

        await exportFile.saveTo(saveLocation.path);
        return Right(saveLocation.path);
      } on UnimplementedError catch (_) {
        final dir = await getApplicationDocumentsDirectory();
        final fallbackPath = '${dir.path}/$suggestedName';
        final file = File(fallbackPath);
        await file.writeAsBytes(bytes, flush: true);
        return Right(fallbackPath);
      }
    } catch (e) {
      developer.log('ERROR AL EXPORTAR PERFIL: $e');
      return Left(DatabaseFailure('Error al exportar la información'));
    }
  }
}
