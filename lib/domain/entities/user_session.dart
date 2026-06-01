import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String gmail;
  final String uuid;

  const UserSession(this.gmail, this.uuid);

  @override
  List<Object> get props => [gmail, uuid];
}
