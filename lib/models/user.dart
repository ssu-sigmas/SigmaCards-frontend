class User {
  final String id; // UUID
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

