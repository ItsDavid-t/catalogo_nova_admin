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
  final int stock;
  final int lowStockAlert;
  final double costPrice;
  final double sellPrice;
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
    this.costPrice = 0.0,
    this.sellPrice = 0.0,
    required this.stock,
    this.lowStockAlert = 0,
    required this.imgUrl,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'stock': stock,
      'lowStockAlert': lowStockAlert,
      'classification': classification?.trim().toLowerCase(),
      'categoryId': categoryId,
      'cost_price': costPrice,
      'sell_price': sellPrice,
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
      stock: (map['stock'] ?? 0) as int,
      lowStockAlert: (map['lowStockAlert'] ?? 0) as int,
      classification: map['classification'] as String?,
      categoryId: map['categoryId'] as int?,
      shopId: (map['shopId'] ?? map['shop_id']) as String?,
      costPrice: (map['cost_price'] ?? 0.0) is num
          ? (map['cost_price']).toDouble()
          : double.tryParse((map['cost_price']).toString()) ?? 0.0,
      sellPrice: (map['sell_price'] ?? 0.0) is num
          ? (map['sell_price']).toDouble()
          : double.tryParse((map['sell_price']).toString()) ?? 0.0,
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
    int? stock,
    int? lowStockAlert,
    double? costPrice,
    double? sellPrice,
    String? imgUrl,
    ProductStatus? status,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      classification: classification ?? this.classification,
      categoryId: categoryId ?? this.categoryId,
      shopId: shopId ?? this.shopId,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      imgUrl: imgUrl ?? this.imgUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isLowStock => stock > 0 && stock < lowStockAlert;

  bool get isEffectivelyOutOfStock =>
      stock <= 0 || status == ProductStatus.outOfStock;

  Product withSyncedStockStatus() {
    if (stock <= 0) {
      return copyWith(status: ProductStatus.outOfStock);
    }
    if (status == ProductStatus.outOfStock) {
      return copyWith(status: ProductStatus.available);
    }
    return this;
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
