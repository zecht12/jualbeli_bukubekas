class BookModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final String userId;
  final String category;
  final String condition;
  final double rating;
  final int stock;

  BookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.userId,
    required this.category,
    required this.condition,
    this.rating = 0.0,
    this.stock = 1,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0,
      imageUrl: json['image_url'] ?? '',
      userId: json['user_id'] ?? '',
      category: json['category'] ?? 'Lainnya',
      condition: json['condition'] ?? 'Bekas',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 1,
    );
  }
}