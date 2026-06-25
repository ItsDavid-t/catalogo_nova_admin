class Category {
  final int? id;
  final String name;
  final int? parentId;
  final String? shopId;

  const Category({this.id, required this.name, this.parentId, this.shopId});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      parentId: map['parent_id'] as int?,
      shopId: map['shop_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'parent_id': parentId, 'shop_id': shopId};
  }
}
