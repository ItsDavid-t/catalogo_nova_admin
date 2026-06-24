import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String email;
  final String userId;

  const UserSession(this.email, this.userId);

  @override
  List<Object> get props => [email, userId];
}
