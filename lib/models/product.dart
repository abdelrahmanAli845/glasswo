class Product {
  final String id;
  final String name;

  Product({required this.id, required this.name});

  factory Product.fromDoc(doc) {
    return Product(
      id: doc.id,
      name: doc['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}