import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/models/pdv_model.dart';
import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String referenceId;

  // Sender information
  final String senderFirstName;
  final String senderLastName;
  final String senderPhone;
  final String senderEmail;
  final String senderAddress;
  final String senderIdType;
  final String senderIdNumber;
  final DateTime? senderIdIssueDate;
  final DateTime senderIdExpiryDate;
  final String senderNationality;
  final DateTime senderBirthDate;
  final String senderBirthPlace;
  final String? senderOccupation;
  final String senderGender;
  final String? senderCountry;

  // Recipient information
  final String recipientFirstName;
  final String recipientLastName;
  final String recipientPhone;
  final String recipientEmail;
  final String recipientAddress;
  final String recipientIdType;
  final String recipientIdNumber;
  final String recipientNationality;
  final DateTime recipientBirthDate;
  final String recipientBirthPlace;
  final String recipientGender;
  final String? recipientCountry;

  // Transaction details
  final double amount;
  final double fees;
  final double totalAmount;
  final String currency;
  final String status;
  final String operatorId;
  final String pdvId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? reason;
  final String? finalTransactionNumber;
  final String? rejectionReason;
  final String? processedBy;
  final DateTime? processedAt;

  // Related entities
  final Operator? operator;
  final PDV? pdv;

  Transaction({
    required this.id,
    required this.referenceId,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderPhone,
    required this.senderEmail,
    required this.senderAddress,
    required this.senderIdType,
    required this.senderIdNumber,
    this.senderIdIssueDate,
    required this.senderIdExpiryDate,
    required this.senderNationality,
    required this.senderBirthDate,
    required this.senderBirthPlace,
    this.senderOccupation,
    required this.senderGender,
    this.senderCountry,
    required this.recipientFirstName,
    required this.recipientLastName,
    required this.recipientPhone,
    required this.recipientEmail,
    required this.recipientAddress,
    required this.recipientIdType,
    required this.recipientIdNumber,
    required this.recipientNationality,
    required this.recipientBirthDate,
    required this.recipientBirthPlace,
    required this.recipientGender,
    this.recipientCountry,
    required this.amount,
    required this.fees,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.operatorId,
    required this.pdvId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.reason,
    this.finalTransactionNumber,
    this.rejectionReason,
    this.processedBy,
    this.processedAt,
    this.operator,
    this.pdv,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    debugPrint(json.toString());
    return Transaction(
      id: json['id'],
      referenceId: json['referenceId'],
      senderFirstName: json['senderFirstName'],
      senderLastName: json['senderLastName'],
      senderPhone: json['senderPhone'],
      senderEmail: json['senderEmail'],
      senderAddress: json['senderAddress'],
      senderIdType: json['senderIdType'],
      senderIdNumber: json['senderIdNumber'],
      senderIdIssueDate: json['senderIdIssueDate'] != null ? DateTime.parse(json['senderIdIssueDate']) : null,
      senderIdExpiryDate: DateTime.parse(json['senderIdExpiryDate']),
      senderNationality: json['senderNationality'],
      senderBirthDate: DateTime.parse(json['senderBirthDate']),
      senderBirthPlace: json['senderBirthPlace'],
      senderOccupation: json['senderOccupation'],
      senderGender: json['senderGender'],
      senderCountry: json['senderCountry'],
      recipientFirstName: json['recipientFirstName'],
      recipientLastName: json['recipientLastName'],
      recipientPhone: json['recipientPhone'],
      recipientEmail: json['recipientEmail'],
      recipientAddress: json['recipientAddress'],
      recipientIdType: json['recipientIdType'],
      recipientIdNumber: json['recipientIdNumber'],
      recipientNationality: json['recipientNationality'],
      recipientBirthDate: DateTime.parse(json['recipientBirthDate']),
      recipientBirthPlace: json['recipientBirthPlace'],
      recipientGender: json['recipientGender'],
      recipientCountry: json['recipientCountry'],
      amount: (json['amount'] as num).toDouble(),
      fees: (json['fees'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      operatorId: json['operatorId'],
      pdvId: json['pdvId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      reason: json['reason'],
      finalTransactionNumber: json['finalTransactionNumber'],
      rejectionReason: json['rejectionReason'],
      processedBy: json['processedBy'],
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      operator: json['operator'] != null ? Operator.fromJson(json['operator']) : null,
      pdv: json['pdv'] != null ? PDV.fromJson(json['pdv']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceId': referenceId,
      'senderFirstName': senderFirstName,
      'senderLastName': senderLastName,
      'senderPhone': senderPhone,
      'senderEmail': senderEmail,
      'senderAddress': senderAddress,
      'senderIdType': senderIdType,
      'senderIdNumber': senderIdNumber,
      'senderIdIssueDate': senderIdIssueDate?.toIso8601String(),
      'senderIdExpiryDate': senderIdExpiryDate.toIso8601String(),
      'senderNationality': senderNationality,
      'senderBirthDate': senderBirthDate.toIso8601String(),
      'senderBirthPlace': senderBirthPlace,
      'senderOccupation': senderOccupation,
      'senderGender': senderGender,
      'senderCountry': senderCountry,
      'recipientFirstName': recipientFirstName,
      'recipientLastName': recipientLastName,
      'recipientPhone': recipientPhone,
      'recipientEmail': recipientEmail,
      'recipientAddress': recipientAddress,
      'recipientIdType': recipientIdType,
      'recipientIdNumber': recipientIdNumber,
      'recipientNationality': recipientNationality,
      'recipientBirthDate': recipientBirthDate.toIso8601String(),
      'recipientBirthPlace': recipientBirthPlace,
      'recipientGender': recipientGender,
      'recipientCountry': recipientCountry,
      'amount': amount,
      'fees': fees,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'operatorId': operatorId,
      'pdvId': pdvId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'reason': reason,
      'finalTransactionNumber': finalTransactionNumber,
      'rejectionReason': rejectionReason,
      'processedBy': processedBy,
      'processedAt': processedAt?.toIso8601String(),
      'operator': operator?.toJson(),
      'pdv': pdv?.toJson(),
    };
  }

  String get senderFullName => '$senderFirstName $senderLastName';
  String get recipientFullName => '$recipientFirstName $recipientLastName';

  String formattedAmount() {
    return '$amount $currency';
  }

  bool isCompleted() {
    return status == 'COMPLETED';
  }
}