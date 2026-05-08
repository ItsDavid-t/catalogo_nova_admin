class Category {
  final int? id;
  final String name;
  final int? parentId;
  Category({this.id, this.parentId, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'parentId': parentId};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      parentId: map['parentId'] as int?,
    );
  }

  Category copyWith({int? id, String? name, int? parentId}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId,
    );
  }

  @override
  String toString() => 'Category(id: $id, name: $name, parentId: $parentId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Category) {
      if (other.id == id && other.name == name && other.parentId == parentId) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(id, name, parentId);
}
