import 'package:bit_money/models/operator_model.dart';

class TransferData {
  // Sender information
  String? senderFirstName;
  String? senderLastName;
  String? senderPhone;
  String? senderEmail;
  String? senderAddress;
  String? senderIdType;
  String? senderIdNumber;
  DateTime? senderIdExpiryDate;
  String? senderNationality;
  DateTime? senderBirthDate;
  String? senderBirthPlace;
  String? senderGender;
  String? senderCountry;

  // Recipient information
  String? recipientFirstName;
  String? recipientLastName;
  String? recipientPhone;
  String? recipientEmail;
  String? recipientAddress;
  String? recipientIdType;
  String? recipientIdNumber;
  String? recipientNationality;
  DateTime? recipientBirthDate;
  String? recipientBirthPlace;
  String? recipientGender;
  String? recipientCountry;

  // Transaction details
  double? amount;
  String? currency;
  String? operatorId;
  String? pdvId;
  double? fees;
  String? reason;
  String? transactionNumber;
  DateTime? transactionDate;
  Operator? operator;
  double? amountReceived;

  Map<String, dynamic> toSenderJson() {
    return {
      "senderFirstName": senderFirstName,
      "senderLastName": senderLastName,
      "senderPhone": senderPhone,
      "senderEmail": senderEmail,
      "senderAddress": senderAddress,
      "senderIdType": senderIdType,
      "senderIdNumber": senderIdNumber,
      "senderIdExpiryDate": senderIdExpiryDate?.toUtc().toIso8601String(),
      "senderNationality": senderNationality,
      "senderBirthDate": senderBirthDate?.toUtc().toIso8601String(),
      "senderBirthPlace": senderBirthPlace,
      "senderGender": senderGender,
      "senderCountry": senderCountry,
      "reason": reason
    };
  }

  Map<String, dynamic> toRecipientJson() {
    return {
      "recipientFirstName": recipientFirstName,
      "recipientLastName": recipientLastName,
      "recipientPhone": recipientPhone,
      "recipientEmail": recipientEmail,
      "recipientAddress": recipientAddress,
      "recipientIdType": recipientIdType,
      "recipientIdNumber": recipientIdNumber,
      "recipientNationality": recipientNationality,
      "recipientBirthDate": recipientBirthDate?.toUtc().toIso8601String(),
      "recipientBirthPlace": recipientBirthPlace,
      "recipientGender": recipientGender,
      "recipientCountry": recipientCountry
    };
  }

  Map<String, dynamic> toAmountJson() {
    return {
      "amount": amount,
      "currency": currency,
      "operatorId": operatorId,
      "pdvId": pdvId,
      "fees": fees
    };
  }
}