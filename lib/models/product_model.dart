class Product {
  final String? id;
  final String? imageUrl;
  final String? title;
  final String? name;
  final String? description;
  final String? author;
  final double? rating;
  final String? price;
  final bool isFavorite;

  Product({
    this.id,
    this.imageUrl,
    this.title,
    this.name,
    this.description,
    this.author,
    this.rating,
    this.price,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      imageUrl: json['imageUrl'],
      title: json['title'],
      author: json['author'],
      rating: json['rating']?.toDouble(),
      price: json['price']?.toString(),
      isFavorite: json['isFavorite'] ?? (json['is_favorite'] == 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'author': author,
      'rating': rating,
      'price': price,
      'isFavorite': isFavorite,
    };
  }
}
