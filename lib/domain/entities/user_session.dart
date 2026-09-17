import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String email;
  final String userId;
  final String role;

  /// ID del dueño de la tienda (admin). Para empleados viene de la invitación.
  final String? ownerId;

  const UserSession(this.email, this.userId, this.role, {this.ownerId});

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isEmployee => role.toLowerCase() == 'employee';

  /// ID de la tienda para catálogo, ventas y categorías.
  /// Admin → su propio userId. Empleado → ownerId del admin.
  String get shopId {
    if (isAdmin) return userId;
    final owner = ownerId?.trim();
    if (owner != null && owner.isNotEmpty) return owner;
    return userId;
  }

  bool get hasShopLink => isAdmin || (ownerId?.trim().isNotEmpty ?? false);

  @override
  List<Object?> get props => [email, userId, role, ownerId];
}
