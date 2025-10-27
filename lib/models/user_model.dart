import 'package:bit_money/models/pdv_model.dart';

class UserModel {
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String id;
  final String role;
  String? phone;
  final String accountType;
  final num commission;
  PDV? pdv;

  UserModel({
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.id,
    required this.role,
    this.phone,
    required this.accountType,
    required this.commission,
    this.pdv,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      accountType: json['accountType'] ?? '',
      commission: json['commission'] ?? 0,
      pdv: json['pdv'] != null ? PDV.fromJson(json['pdv']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'phone': phone,
      'accountType': accountType,
      'commission': commission,
      'pdv': pdv?.toJson(),
    };
  }
}