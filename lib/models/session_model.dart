import 'package:bit_money/extensions/extensions.dart';
import 'package:bit_money/models/user_model.dart';

class SessionModel {
  final UserModel? user;
  final DateTime expires;

  SessionModel({
    this.user,
    required this.expires,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      expires: json['expires'] != null ? DateTime.parse(json['expires']) : DateTime.now().add(const Duration(hours: 1)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'expires': expires.toISOString(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expires);
  bool get isValid => user != null && !isExpired;
}