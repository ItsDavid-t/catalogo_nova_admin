class Category {
  final int? id;
  final String name;
  final int? parentId;
  final String? shopId;

  Category({this.id, this.parentId, required this.name, this.shopId});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'id': id, 'name': name, 'parentId': parentId};
    if (shopId != null) {
      map['shop_id'] = shopId;
    }
    return map;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      parentId: map['parentId'] as int?,
      shopId: (map['shopId'] ?? map['shop_id']) as String?,
    );
  }

  Category copyWith({int? id, String? name, int? parentId, String? shopId}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      shopId: shopId ?? this.shopId,
    );
  }

  @override
  String toString() =>
      'Category(id: $id, name: $name, parentId: $parentId, shopId: $shopId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Category) {
      return other.id == id &&
          other.name == name &&
          other.parentId == parentId &&
          other.shopId == shopId;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, shopId);
}
