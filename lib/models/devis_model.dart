class Devis {
  final int id;
  final String userId;
  final String operatorId;
  final num? amountToSend;
  final num? amountToReceive;
  final String currency;
  final String recipientCurrency;
  final String recipientCountry;
  final String createdAt;
  final User user;
  final Operateur operateur;
  final ReponseDevis? reponseDevis;

  Devis({
    required this.id,
    required this.userId,
    required this.operatorId,
    this.amountToSend,
    this.amountToReceive,
    required this.currency,
    required this.recipientCurrency,
    required this.recipientCountry,
    required this.createdAt,
    required this.user,
    required this.operateur,
    this.reponseDevis,
  });

  factory Devis.fromJson(Map<String, dynamic> json) {
    return Devis(
      id: json['id'],
      userId: json['userId'],
      operatorId: json['operatorId'],
      amountToSend: json['amountToSend'],
      amountToReceive: json['amountToReceive'],
      currency: json['currency'],
      recipientCurrency: json['recipientCurrency'],
      recipientCountry: json['recipientCountry'],
      createdAt: json['createdAt'],
      user: User.fromJson(json['user']),
      operateur: Operateur.fromJson(json['operateur']),
      reponseDevis: json['reponseDevis'] != null
        ? ReponseDevis.fromJson(json['reponseDevis'])
        : null,
    );
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String accountType;
  final num commission;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.accountType,
    required this.commission,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      accountType: json['accountType'],
      commission: json['commission'],
    );
  }
}

class Operateur {
  final String id;
  final String name;
  final String code;
  final String logo;
  final String description;
  final bool isActive;
  final int minAmount;
  final int maxAmount;
  final num fees;

  Operateur({
    required this.id,
    required this.name,
    required this.code,
    required this.logo,
    required this.description,
    required this.isActive,
    required this.minAmount,
    required this.maxAmount,
    required this.fees,
  });

  factory Operateur.fromJson(Map<String, dynamic> json) {
    return Operateur(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      logo: json['logo'],
      description: json['description'],
      isActive: json['isActive'],
      minAmount: json['minAmount'],
      maxAmount: json['maxAmount'],
      fees: json['fees'],
    );
  }
}

class ReponseDevis {
  final int id;
  final int demandeDevisId;
  final num amountToSend;
  final num amountToReceive;
  final String currency;
  final String receiveCurrency;
  final num fees;
  final String createdAt;

  ReponseDevis({
    required this.id,
    required this.demandeDevisId,
    required this.amountToSend,
    required this.amountToReceive,
    required this.currency,
    required this.receiveCurrency,
    required this.fees,
    required this.createdAt,
  });

  factory ReponseDevis.fromJson(Map<String, dynamic> json) {
    return ReponseDevis(
      id: json['id'],
      demandeDevisId: json['demandeDevisId'],
      amountToSend: json['amountToSend'],
      amountToReceive: json['amountToReceive'],
      currency: json['currency'],
      receiveCurrency: json['receiveCurrency'],
      fees: json['fees'],
      createdAt: json['createdAt'],
    );
  }
}