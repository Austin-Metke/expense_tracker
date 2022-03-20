import 'dart:convert';
import 'dart:io';

class Receipt {
  double? total;
  File? image;
  String? comment;

  toJson() => _serializeToJson(this);

  Receipt({required this.total, this.image, this.comment});

  Map<String, dynamic> _serializeToJson(Receipt receipt) {
    if (receipt.image == null) {
      return <String, dynamic>{
        'total': receipt.total,
        'comment': receipt.comment,
      };
    } else {
      final _imageAsBytes =
          File(receipt.image!.absolute.path).readAsBytesSync();
      final _b64Enc = base64Encode(_imageAsBytes);

      return <String, dynamic>{
        'image': _b64Enc,
        'total': receipt.total,
        'comment': receipt.comment,
        'date': DateTime.now().microsecondsSinceEpoch,
      };
    }
  }
}
