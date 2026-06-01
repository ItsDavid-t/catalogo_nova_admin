import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserSession userSession;

  const AuthAuthenticated(this.userSession);

  @override
  List<Object?> get props => [userSession];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;
  final bool suggestRegistration;

  const AuthFailure(
    this.message, {
    this.suggestRegistration = false,
  });

  @override
  List<Object?> get props => [message, suggestRegistration];
}
