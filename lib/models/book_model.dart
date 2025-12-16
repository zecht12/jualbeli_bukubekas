class BookModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final String category;
  final String condition;
  final bool isSold;
  final DateTime createdAt;

  BookModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category = 'Umum',
    this.condition = 'Bekas',
    this.isSold = false,
    required this.createdAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'].toString(),
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] ?? '',
      price: json['price'] as int,
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'Umum',
      condition: json['condition'] ?? 'Bekas',
      isSold: json['is_sold'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'condition': condition,
      'is_sold': isSold,
      'created_at': createdAt,
    };
  }
}