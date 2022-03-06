import 'dart:convert';
import 'dart:io';

class Receipt {


  double? _receiptTotal;
  File? _receiptImage;
  String? _receiptComment;
  toJson() => _serializeToJson(this);


  Receipt({required double? total, required File? image, String? comment}) {

    _receiptTotal = total;
    _receiptImage = image;
    _receiptComment = comment;

  }

   Map<String, dynamic> _serializeToJson(Receipt receipt)  {

    
   final _imageAsBytes = File(receipt._receiptImage!.absolute.path).readAsBytesSync();

   final _b64Enc = base64Encode(_imageAsBytes);


    return <String, dynamic>{

      'image': _b64Enc,
      'total': receipt._receiptTotal,
      'comment': receipt._receiptComment,
      'date': DateTime.now().microsecondsSinceEpoch,
    };

  }



}