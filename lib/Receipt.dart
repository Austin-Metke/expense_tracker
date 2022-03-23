import 'dart:convert';
import 'dart:io';

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


  toJson() => _serializeToJson(this);

  Receipt({required this.total, required this.expenseType, this.image, this.comment});

  Map<String, dynamic> _serializeToJson(Receipt receipt) {
    if (receipt.image == null) {
      return <String, dynamic>{
        'total': receipt.total,
        'comment': receipt.comment,
      };
    } else {
      final _imageAsBytes = File(receipt.image!.absolute.path).readAsBytesSync();
      final _b64Enc = base64Encode(_imageAsBytes);

      return <String, dynamic>{
        'image': _b64Enc,
        'total': receipt.total,
        'comment': receipt.comment,
        'expenseType': receipt.expenseType,
        'date': DateTime.now().microsecondsSinceEpoch,
      };
    }
  }
}
