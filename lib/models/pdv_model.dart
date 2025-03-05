class PDV {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String openingTime;
  final String closingTime;
  final bool openWeekend;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PDV({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.openingTime,
    required this.closingTime,
    required this.openWeekend,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PDV.fromJson(Map<String, dynamic> json) {
    return PDV(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      phone: json['phone'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      openWeekend: json['openWeekend'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'openWeekend': openWeekend,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
