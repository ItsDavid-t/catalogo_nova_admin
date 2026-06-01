import 'dart:async';

import 'package:echo_stock/domain/entities/user_session.dart';
import 'package:echo_stock/domain/usecases/auth/get_current_session.dart';
import 'package:echo_stock/domain/usecases/auth/sign_in.dart';
import 'package:echo_stock/domain/usecases/auth/sign_out.dart';
import 'package:echo_stock/domain/usecases/auth/sign_up.dart';
import 'package:echo_stock/domain/usecases/auth/watch_auth_session.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final GetCurrentSession _getCurrentSession;
  final WatchAuthSession _watchAuthSession;

  StreamSubscription<UserSession?>? _authSubscription;
  bool _handlingAuthAction = false;

  AuthCubit(
    this._signIn,
    this._signUp,
    this._signOut,
    this._getCurrentSession,
    this._watchAuthSession,
  ) : super(const AuthInitial()) {
    _authSubscription = _watchAuthSession().listen(_onSessionChanged);
    checkSession();
  }

  UserSession? get currentSession {
    final current = state;
    if (current is AuthAuthenticated) {
      return current.userSession;
    }
    return null;
  }

  Future<void> checkSession() async {
    emit(const AuthLoading());
    final result = await _getCurrentSession();
    result.fold((failure) => emit(AuthFailure(failure.message)), (session) {
      if (session == null) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(session));
      }
    });
  }

  void clearFailure() {
    if (state is AuthFailure) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    _handlingAuthAction = true;
    emit(const AuthLoading());
    final result = await _signIn(email: email, password: password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(AuthAuthenticated(session)),
    );
    _handlingAuthAction = false;
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    _handlingAuthAction = true;
    emit(const AuthLoading());
    final result = await _signUp(email: email, password: password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(AuthAuthenticated(session)),
    );
    _handlingAuthAction = false;
  }

  Future<void> logout() async {
    _handlingAuthAction = true;
    emit(const AuthLoading());
    final result = await _signOut();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
    Future.microtask(() {
      _handlingAuthAction = false;
    });
  }

  void _onSessionChanged(UserSession? session) {
    if (_handlingAuthAction) {
      return;
    }

    if (session == null && state is AuthFailure) {
      return;
    }

    if (session == null) {
      if (state is AuthAuthenticated) {
        emit(const AuthUnauthenticated());
      }
      return;
    }

    emit(AuthAuthenticated(session));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
