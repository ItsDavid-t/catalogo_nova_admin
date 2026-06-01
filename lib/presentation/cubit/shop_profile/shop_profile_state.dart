import 'package:echo_stock/domain/entities/shop_profile.dart';
import 'package:equatable/equatable.dart';

abstract class ShopProfileState extends Equatable {
  const ShopProfileState();

  @override
  List<Object?> get props => [];
}

class ShopProfileInitial extends ShopProfileState {
  const ShopProfileInitial();
}

class ShopProfileLoading extends ShopProfileState {
  const ShopProfileLoading();
}

class ShopProfileLoaded extends ShopProfileState {
  final ShopProfile profile;

  const ShopProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ShopProfileMissing extends ShopProfileState {
  final String userId;

  const ShopProfileMissing(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ShopProfileSaving extends ShopProfileState {
  final ShopProfile? draft;

  const ShopProfileSaving([this.draft]);

  @override
  List<Object?> get props => [draft];
}

class ShopProfileSaved extends ShopProfileState {
  final ShopProfile profile;

  const ShopProfileSaved(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ShopProfileFailure extends ShopProfileState {
  final String message;

  const ShopProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
