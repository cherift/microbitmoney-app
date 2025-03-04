class UserModel {
  final String name;
  final String email;
  final String id;
  final String role;

  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      id: json['id'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'id': id,
      'role': role,
    };
  }
}