import 'package:bit_money/models/pdv_model.dart';

class UserModel {
  final String name;
  final String email;
  final String id;
  final String role;
  final String accountType;
  final int commission;
  PDV? pdv;

  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.role,
    required this.accountType,
    required this.commission,
    this.pdv,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accountType: json['accountType'] ?? '',
      commission: json['commission'] ?? '',
      pdv: json['pdv'] != null ? PDV.fromJson(json['pdv']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'accountType': accountType,
      'commission': commission,
      'pdv': pdv?.toJson(),
    };
  }
}