enum ProductStatus { available, reserved, outOfStock }

extension ProductStatusLabel on ProductStatus {
  String get displayName {
    switch (this) {
      case ProductStatus.available:
        return 'Disponible';
      case ProductStatus.reserved:
        return 'Reservado';
      case ProductStatus.outOfStock:
        return 'Sin stock';
    }
  }
}

class Product {
  final int? id;
  final String name;
  final String? description;
  final String? classification;
  final int? categoryId;
  final String? shopId;
  final String imgUrl;
  final ProductStatus status;
  final DateTime createdAt;

  const Product({
    this.id,
    required this.name,
    this.description,
    this.classification,
    this.categoryId,
    this.shopId,
    required this.imgUrl,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'classification': classification?.trim().toLowerCase(),
      'categoryId': categoryId,
      'imgUrl': imgUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
    if (shopId != null) {
      map['shop_id'] = shopId;
    }
    return map;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      classification: map['classification'] as String?,
      categoryId: map['categoryId'] as int?,
      shopId: (map['shopId'] ?? map['shop_id']) as String?,
      imgUrl: (map['imgUrl'] ?? '') as String,
      status: _statusFromString((map['status'] ?? 'available') as String),
      createdAt:
          DateTime.tryParse((map['createdAt'] ?? '') as String) ??
          DateTime.now(),
    );
  }

  static ProductStatus _statusFromString(String status) {
    switch (status) {
      case 'reserved':
        return ProductStatus.reserved;
      case 'outOfStock':
        return ProductStatus.outOfStock;
      default:
        return ProductStatus.available;
    }
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? classification,
    int? categoryId,
    String? shopId,
    String? imgUrl,
    ProductStatus? status,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      classification: classification ?? this.classification,
      categoryId: categoryId ?? this.categoryId,
      shopId: shopId ?? this.shopId,
      imgUrl: imgUrl ?? this.imgUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusLabel {
    switch (status) {
      case ProductStatus.available:
        return 'Disponible';
      case ProductStatus.reserved:
        return 'Reservado';
      case ProductStatus.outOfStock:
        return 'Sin Stock';
    }
  }
}
