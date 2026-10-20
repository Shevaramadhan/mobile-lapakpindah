class Product {
  final int id;
  final String name;
  final int sellingPrice;
  final bool isActive;
  const Product({required this.id, required this.name, required this.sellingPrice, this.isActive = true});
  Product copyWith({int? id, String? name, int? sellingPrice, bool? isActive}) => Product(id: id ?? this.id, name: name ?? this.name, sellingPrice: sellingPrice ?? this.sellingPrice, isActive: isActive ?? this.isActive);
  factory Product.fromMap(Map<String, Object?> map) => Product(id: map['id'] as int, name: map['name'] as String, sellingPrice: map['selling_price'] as int, isActive: (map['is_active'] as int) == 1);
  Map<String, Object?> toMap() => {'id': id, 'name': name, 'selling_price': sellingPrice, 'is_active': isActive ? 1 : 0};
}
