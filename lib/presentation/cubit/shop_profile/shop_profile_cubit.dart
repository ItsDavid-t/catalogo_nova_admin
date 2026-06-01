import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:echo_stock/domain/usecases/shop_profile/get_shop_profile.dart';
import 'package:echo_stock/domain/usecases/shop_profile/upsert_shop_profile.dart';
import 'package:echo_stock/presentation/cubit/shop_profile/shop_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShopProfileCubit extends Cubit<ShopProfileState> {
  final GetShopProfile _getShopProfile;
  final UpsertShopProfile _upsertShopProfile;

  ShopProfileCubit(this._getShopProfile, this._upsertShopProfile)
    : super(const ShopProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(const ShopProfileLoading());
    final result = await _getShopProfile(userId);
    result.fold(
      (failure) => emit(ShopProfileFailure(failure.message)),
      (profile) {
        if (profile == null) {
          emit(ShopProfileMissing(userId));
        } else {
          emit(ShopProfileLoaded(profile));
        }
      },
    );
  }

  Future<void> saveProfile(ShopProfile profile) async {
    emit(ShopProfileSaving(profile));
    final result = await _upsertShopProfile(profile);
    result.fold(
      (failure) => emit(ShopProfileFailure(failure.message)),
      (_) => emit(ShopProfileSaved(profile)),
    );
  }
}
