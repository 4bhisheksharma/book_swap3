class Book {
  final String id;
  final String name;
  final String description;
  final int credit;
  final double price;
  final String image;

  Book({
    required this.id,
    required this.name,
    required this.description,
    required this.credit,
    required this.price,
    required this.image,
  });

  // Add copyWith method
  Book copyWith({
    String? id,
    String? name,
    String? description,
    int? credit,
    double? price,
    String? image,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      credit: credit ?? this.credit,
      price: price ?? this.price,
      image: image ?? this.image,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'http://10.0.2.2:8000/media/$imageUrl';
    }
    return Book(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      credit: json['credit'] as int,
      price: double.parse(json['price'].toString()),
      image: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgajiszqbIidBTizWtlpW1JWsuxjgbTLxN5Q&s', //placeholder image
    );
  }
}
