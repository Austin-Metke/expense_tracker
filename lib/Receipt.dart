import 'dart:convert';
import 'dart:io';

class Receipt {


  double? _receiptTotal;
  File? _receiptImage;
  toJson() => _serializeToJson(this);


  Receipt({required double? total, required File? image }) {

    _receiptTotal = total;
    _receiptImage = image;

  }

   Map<String, dynamic> _serializeToJson(Receipt receipt)  {

    
   var imageAsBytes = File(receipt._receiptImage.toString().substring(0, receipt._receiptImage.toString().length - 1).substring(7)).readAsBytesSync();

   var b64Enc = base64Encode(imageAsBytes);


    return <String, dynamic>{

      'image': b64Enc,
      'total': receipt._receiptTotal

    };

  }



}