import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/models/pdv_model.dart';

class Reception {
  final String id;
  final String referenceId;

  // Sender information
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderPhone;
  final String? senderEmail;
  final String? senderAddress;
  final String? senderIdType;
  final String? senderIdNumber;
  final DateTime? senderIdExpiryDate;
  final String? senderNationality;
  final DateTime? senderBirthDate;
  final String? senderBirthPlace;
  final String? senderGender;
  final String? senderCountry;

  // Recipient information
  final String recipientFirstName;
  final String recipientLastName;
  final String recipientPhone;
  final String recipientEmail;
  final String recipientAddress;
  final String recipientIdType;
  final String recipientIdNumber;
  final String recipientCountry;
  final String recipientNationality;
  final DateTime recipientBirthDate;
  final String recipientBirthPlace;
  final String recipientGender;

  // Transaction details
  final String? reason;
  final double? amount;
  final String? currency;
  final String status;
  final String operatorId;
  final String? pdvId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? rejectionReason;
  final String? processedBy;
  final DateTime? processedAt;

  // Related entities
  final Operator operator;
  final PDV? pdv;

  Reception({
    required this.id,
    required this.referenceId,
    this.senderFirstName,
    this.senderLastName,
    this.senderPhone,
    this.senderEmail,
    this.senderAddress,
    this.senderIdType,
    this.senderIdNumber,
    this.senderIdExpiryDate,
    this.senderNationality,
    this.senderBirthDate,
    this.senderBirthPlace,
    this.senderGender,
    this.senderCountry,
    required this.recipientFirstName,
    required this.recipientLastName,
    required this.recipientPhone,
    required this.recipientEmail,
    required this.recipientAddress,
    required this.recipientIdType,
    required this.recipientIdNumber,
    required this.recipientCountry,
    required this.recipientNationality,
    required this.recipientBirthDate,
    required this.recipientBirthPlace,
    required this.recipientGender,
    this.reason,
    this.amount,
    this.currency,
    required this.status,
    required this.operatorId,
    this.pdvId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.rejectionReason,
    this.processedBy,
    this.processedAt,
    required this.operator,
    this.pdv,
  });

  factory Reception.fromJson(Map<String, dynamic> json) {
    return Reception(
      id: json['id'],
      referenceId: json['referenceId'],
      senderFirstName: json['senderFirstName'],
      senderLastName: json['senderLastName'],
      senderPhone: json['senderPhone'],
      senderEmail: json['senderEmail'],
      senderAddress: json['senderAddress'],
      senderIdType: json['senderIdType'],
      senderIdNumber: json['senderIdNumber'],
      senderIdExpiryDate: json['senderIdExpiryDate'] != null
          ? DateTime.parse(json['senderIdExpiryDate'])
          : null,
      senderNationality: json['senderNationality'],
      senderBirthDate: json['senderBirthDate'] != null
          ? DateTime.parse(json['senderBirthDate'])
          : null,
      senderBirthPlace: json['senderBirthPlace'],
      senderGender: json['senderGender'],
      senderCountry: json['senderCountry'],
      recipientFirstName: json['recipientFirstName'],
      recipientLastName: json['recipientLastName'],
      recipientPhone: json['recipientPhone'],
      recipientEmail: json['recipientEmail'],
      recipientAddress: json['recipientAddress'],
      recipientIdType: json['recipientIdType'],
      recipientIdNumber: json['recipientIdNumber'],
      recipientCountry: json['recipientCountry'],
      recipientNationality: json['recipientNationality'],
      recipientBirthDate: DateTime.parse(json['recipientBirthDate']),
      recipientBirthPlace: json['recipientBirthPlace'],
      recipientGender: json['recipientGender'],
      reason: json['reason'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'],
      status: json['status'],
      operatorId: json['operatorId'],
      pdvId: json['pdvId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      rejectionReason: json['rejectionReason'],
      processedBy: json['processedBy'],
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      operator: Operator.fromJson(json['operator']),
      pdv: json['pdv'] != null ? PDV.fromJson(json['pdv']) : null,
    );
  }

  String get senderFullName =>
      (senderFirstName != null && senderLastName != null)
          ? '$senderFirstName $senderLastName'
          : 'N/A';

  String get recipientFullName => '$recipientFirstName $recipientLastName';

  String formattedAmount() {
    return amount != null && currency != null ? '$amount $currency' : 'N/A';
  }

  bool isCompleted() {
    return status == 'COMPLETED';
  }

  bool isPending() {
    return status == 'PENDING';
  }
}