class Contact {
  String firstName;
  String lastName;
  String phone;
  String email;
  String address;
  String location;
  String imagePath;
  String country;
  bool isFavorite;
  DateTime timestamp;
  String category; // New: e.g., "Work", "Family", "Friends"
  int rating; // New: 1-5 stars

  Contact({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.address = '',
    this.location = '',
    this.imagePath = '',
    this.country = '',
    this.isFavorite = false,
    DateTime? timestamp,
    this.category = 'Friends', // Default category
    this.rating = 3, // Default rating
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'location': location,
      'imagePath': imagePath,
      'country': country,
      'isFavorite': isFavorite,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'rating': rating,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      location: json['location'],
      imagePath: json['imagePath'],
      country: json['country'],
      isFavorite: json['isFavorite'] ?? false,
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      category: json['category'] ?? 'Friends',
      rating: json['rating'] ?? 3,
    );
  }

  String get fullName => '$firstName $lastName';
}
