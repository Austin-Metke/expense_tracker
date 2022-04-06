import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

@immutable
abstract class ExpenseType {
  static const String travel = 'Travel';
  static const String food = 'Food';
  static const String other = 'Other';
  static const String tools = 'Tools';
}

class Receipt {
  double? total;
  File? image;
  String? comment;
  String? expenseType;

  Receipt(
      {required this.total,
      required this.expenseType,
      required this.image,
      this.comment});

  toJson() => _serializeToJson(this);

  ///When updating a [Receipt], a user may not update its [image]. if the [image] passed in is null,
  ///we will only [total] [expenseType] and [total]
  Map<String, dynamic> _serializeToJson(Receipt receipt) {
    if (receipt.image == null) {
      return <String, dynamic>{
        'total': receipt.total,
        'comment': receipt.comment,
        'expenseType': receipt.expenseType,
      };
    } else {
      final imageAsBytes = File(receipt.image!.absolute.path).readAsBytesSync();
      final serializedImage = base64Encode(imageAsBytes);

      return <String, dynamic>{
        'image': serializedImage,
        'total': receipt.total,
        'comment': receipt.comment,
        'expenseType': receipt.expenseType,
        'date': DateTime.now().microsecondsSinceEpoch,
      };
    }
  }
}
