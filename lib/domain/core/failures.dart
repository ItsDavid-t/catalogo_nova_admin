import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class AuthenticationFailure extends Failure {
  final bool suggestRegistration;

  const AuthenticationFailure(
    super.message, {
    this.suggestRegistration = false,
  });

  @override
  List<Object?> get props => [message, suggestRegistration];
}
