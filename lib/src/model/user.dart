class User {
  final String name;
  final String email;
  // Añade más campos si es necesario

  User({required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
    );
  }
}
