class Operator {
  final String id;
  final String name;
  final String code;
  final String logo;
  final String description;
  final bool isActive;
  final double minAmount;
  final double maxAmount;
  final double fees;
  final DateTime createdAt;
  final DateTime updatedAt;

  Operator({
    required this.id,
    required this.name,
    required this.code,
    required this.logo,
    required this.description,
    required this.isActive,
    required this.minAmount,
    required this.maxAmount,
    required this.fees,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      logo: json['logo'],
      description: json['description'],
      isActive: json['isActive'],
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      fees: (json['fees'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'logo': logo,
      'description': description,
      'isActive': isActive,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'fees': fees,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}