class ShopProfile {
  final String id;
  final String shopName;
  final String whatsappNumber;
  final String? telegramUsername;
  final String? description;
  final String? logoUrl;
  final DateTime createdAt;

  const ShopProfile({
    required this.id,
    required this.shopName,
    required this.whatsappNumber,
    this.telegramUsername,
    this.description,
    this.logoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'whatsapp_number': whatsappNumber,
      'telegram_username': telegramUsername,
      'description': description,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ShopProfile.fromMap(Map<String, dynamic> map) {
    return ShopProfile(
      id: map['id'] as String,
      shopName: map['shop_name'] as String,
      whatsappNumber: map['whatsapp_number'] as String,
      telegramUsername: map['telegram_username'] as String?,
      description: map['description'] as String?,
      logoUrl: map['logo_url'] as String?,
      createdAt:
          DateTime.tryParse((map['created_at'] ?? '') as String) ??
          DateTime.now(),
    );
  }

  ShopProfile copyWith({
    String? id,
    String? shopName,
    String? whatsappNumber,
    String? telegramUsername,
    String? description,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return ShopProfile(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      telegramUsername: telegramUsername ?? this.telegramUsername,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
